package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    import com.greensock.TweenLite;

    public class View
    {
        private static var itemClasses:Object = {
            landfill:   ItemLandfill,
            recycle:   ItemRecycle,
            AluminumCan:   ItemAluminumCan,
            PlasticBottle:   ItemPlasticBottle,
            Styrofoam:   ItemStyrofoam,
            PlasticBag:   ItemPlasticBag
        }

        internal var main:Main;
        internal var model:Model;
        private var countdown:Countdown;
        private var garbage:Array;
        private var pointClip:PointClip;
        private var queue:Array;

        public function View()
        {
            countdown = new Countdown();
        }

        internal function populate(model:Model, main:Main):void
        {
            this.model = model;
            this.main = main;
            countdown.setup(Model.seconds, main.time_txt);
        }

        private function populateQueue(queueModel:Array):void
        {
            queue = [];
            garbage = [];
            for (var i:int = queueModel.length - 1; 0 <= i; i--) {
                var itemClass:Class = itemClasses[queueModel[i]];
                var item:DisplayObjectContainer = new itemClass();
                item.cacheAsBitmap = true;
                queue.unshift(item);
                garbage.unshift(item);
            }
        }

        private function answer(name:String):void
        {
            countdown.start();
            var correct:Boolean = model.answer(name);
            pointClip = point(main.input[name]);
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
            var winning:int = model.update(countdown.remaining);
            return winning;
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
