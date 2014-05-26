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

        internal var main:Main;
        internal var model:Model;
        private var countdown:Countdown;
        private var garbage:Array;
        private var player:DisplayObject;
        private var pointClip:PointClip;

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
            for (var r:int = 0; r < map.length; r++) {
                for (var c:int = 0; c < map[r].length; c++) {
                    var key:String = map[r][c];
                    var name:String;
                    var item:DisplayObject;
                    if (key in Model.items) {
                        name = Model.items[key];
                        var itemClass:Class = itemClasses[name];
                    }
                    else {
                        throw new Error("Unknown key " + key);
                    }
                    if ("Floor" != name) {
                        item = place(new Floor, c, r, main.input.map);
                    }
                    item = place(new itemClass, c, r, main.input.map);
                    if ("Player" == name) {
                        player = item;
                    }
                }
                garbage.unshift(item);
            }
            updatePosition();
        }

        private function place(item:DisplayObject, c:int, r:int, map:DisplayObjectContainer):DisplayObject
        {
            item.cacheAsBitmap = true;
            item.x = c * tile.width;
            item.y = r * tile.height;
            map.addChild(item);
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
            var winning:int = model.update(countdown.remaining);
            return winning;
        }

        private function updatePosition():void
        {
            main.input.map.addChild(player);
            player.x = model.playerColumn * tile.width;
            player.y = model.playerRow * tile.height;
            main.input.map.x = -player.x;
            main.input.map.y = -player.y;
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
