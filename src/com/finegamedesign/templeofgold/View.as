package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    import com.greensock.TweenLite;

    public class View
    {
        private static var tile:Tile = new Tile();

        private static var itemClasses:Object = {
            "Player":   Player,
            "Wall":   Wall,
            "Floor":   Floor,
            "Gold":   Gold,
            "Stairs":   Stairs
        }

        private static var lockClasses:Array = [
            Lock0,
            Lock1,
            Lock2,
            Lock3
        ];

        private static var keyClasses:Array = [
            Key0,
            Key1,
            Key2,
            Key3
        ];

        internal var main:Main;
        internal var model:Model;
        private var countdown:Countdown;
        private var garbage:Array;
        private var golds:Object;
        private var player:DisplayObjectContainer;
        private var pointClip:PointClip;
        private var keys:Array;

        public function View()
        {
            countdown = new Countdown();
        }

        internal function populate(model:Model, main:Main):void
        {
            this.model = model;
            this.main = main;
            countdown.setup(Model.seconds, main.time_txt);
            populateMap(model.map);
        }

        private function populateMap(map:Array):void
        {
            garbage = [];
            golds = {};
            keys = [];
            // Model.shuffle(lockClasses);
            // Model.shuffle(keyClasses);
            var itemClass:Class;
            for (var r:int = 0; r < map.length; r++) {
                for (var c:int = 0; c < map[r].length; c++) {
                    var key:String = map[r][c];
                    var name:String;
                    var item:DisplayObjectContainer;
                    var keyIndex:int = Model.keys.indexOf(key);
                    var lockIndex:int = Model.locks.indexOf(key);
                    if (key in Model.items || 0 <= keyIndex || 0 <= lockIndex) {
                        name = Model.items[key];
                        itemClass = itemClasses[name];
                    }
                    else {
                        throw new Error("Unknown key " + key);
                    }
                    if ("Floor" != name) {
                        item = place(new Floor, c, r, main.input.map);
                    }
                    if ("Player" == name) {
                        item = new itemClass();
                        player = item;
                    }
                    else if ("Gold" == name) {
                        item = new itemClass();
                        golds[model.at(c, r)] = item;
                    }
                    else if ("Wall" == name) {
                        item = new itemClass();
                    }
                    else if ("Floor" == name) {
                        item = new itemClass();
                    }
                    else if ("Stairs" == name) {
                        item = new itemClass();
                    }
                    else {
                        if (0 <= keyIndex) {
                            itemClass = keyClasses[keyIndex];
                            item = new itemClass();
                            keys[keyIndex] = item;
                        }
                        else if (0 <= lockIndex) {
                            itemClass = lockClasses[lockIndex];
                            item = new itemClass();
                        }
                    }
                    item = place(item, c, r, main.input.map);
                }
            }
            updatePosition();
        }

        private function place(item:DisplayObjectContainer, c:int, r:int, map:DisplayObjectContainer):DisplayObjectContainer
        {
            item.cacheAsBitmap = true;
            item.x = c * tile.width;
            item.y = r * tile.height;
            map.addChild(item);
            garbage.unshift(item);
            return item;
        }

        private function answer(name:String):void
        {
            countdown.start();
            var correct:Boolean = model.answer(name);
            if (correct) {
                pointClip = point(main.input);
            }
            main.answer(correct);
        }

        private function point(target:DisplayObject):PointClip
        {
            var point:PointClip = new PointClip();
            point.x = target.x;
            point.y = target.y;
            point.mouseChildren = false;
            point.mouseEnabled = false;
            point.txt.text = model.point.toString();
            garbage.push(point);
            return point;
        }

        internal function update():int
        {
            if (main.keyMouse.justPressed("LEFT")) {
                answer("LEFT");
            }
            else if (main.keyMouse.justPressed("RIGHT")) {
                answer("RIGHT");
            }
            else if (main.keyMouse.justPressed("UP")) {
                answer("UP");
            }
            else if (main.keyMouse.justPressed("DOWN")) {
                answer("DOWN");
            }
            updatePosition();
            updateCarrying();
            var winning:int = model.update(countdown.remaining);
            return winning;
        }

        private function updatePosition():void
        {
            var gold:DisplayObject = golds[model.at(model.playerColumn, model.playerRow)];
            if (gold && gold.parent) {
                gold.parent.removeChild(gold);
            }
            main.input.map.addChild(player);
            player.x = model.playerColumn * tile.width;
            player.y = model.playerRow * tile.height;
            main.input.map.x = -player.x;
            main.input.map.y = -player.y;
        }

        private function updateCarrying():void
        {
            if (0 <= model.carryingIndex) {
                keys[model.carryingIndex].x = 0;
                keys[model.carryingIndex].y = 0;
                player.addChild(keys[model.carryingIndex]);
            }
            if (0 <= model.droppingIndex) {
                place(keys[model.droppingIndex], model.playerColumn, 
                    model.playerRow, main.input.map);
                model.droppingIndex = -1;
            }
        }

        private function remove(garbage:Array):void
        {
            for each(var item:DisplayObject in garbage) {
                if (item.parent) {
                    item.parent.removeChild(item);
                }
            }
            garbage.length = 0;
        }

        internal function clear():void
        {
            countdown.stop();
            remove(garbage);
            if (model) {
                model.clear();
            }
        }
    }
}
