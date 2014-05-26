package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    import com.greensock.TweenLite;

    public class View
    {
        private static var filters:Array = [
            new Filter0().getChildAt(0).filters,
            new Filter1().getChildAt(0).filters,
            new Filter2().getChildAt(0).filters,
            new Filter3().getChildAt(0).filters
        ];

        private static var itemClasses:Object = {
            landfill:   ItemLandfill,
            recycle:   ItemRecycle,
            AluminumCan:   ItemAluminumCan,
            PlasticBottle:   ItemPlasticBottle,
            Styrofoam:   ItemStyrofoam,
            PlasticBag:   ItemPlasticBag
        }

        internal var main:Main;
        internal var onCorrect:Function;
        internal var model:Model;
        private var bindings:Object = {
            landfill: "LEFT",
            recycle: "RIGHT"
        }
        private var buttonXs:Object = {};
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
            populateQueue(model.queue);
            populateSwap();
            countdown.setup(Model.seconds, main.time_txt);
        }

        private function populateQueue(queueModel:Array):void
        {
            queue = [];
            garbage = [];
            for (var i:int = queueModel.length - 1; 0 <= i; i--) {
                var itemClass:Class = itemClasses[queueModel[i]];
                var item:DisplayObjectContainer = new itemClass();
                item.x = main.input.head.x;
                item.y = queueY(i);
                var f:int = Math.random() * model.filters;
                item.filters = filters[f];
                item.mouseChildren = false;
                item.mouseEnabled = false;
                item.cacheAsBitmap = true;
                queue.unshift(item);
                garbage.unshift(item);
                var index:int = main.input.getChildIndex(main.input.head);
                main.input.addChildAt(item, index);
            }
        }

        private function queueY(i:int):int
        {
            return main.input.head.y - int(i * main.input.head.height);
        }

        private function answer(name:String):void
        {
            countdown.start();
            var correct:Boolean = model.answer(name);
            pointClip = point(main.input[name]);
            updateSwap();
            shift(main.input[name]);
            main.answer(correct, pointClip);
        }

        private function shift(target:DisplayObjectContainer):void
        {
            var time:Number = 0.2;
            var answering:DisplayObject = queue.shift();
            main.input.addChild(answering);
            var r:int = Math.random() * target.width / 3;
            var x:int = r + buttonXs[target.name];
            TweenLite.to(answering, time, {x: x, y: target.y,
                onComplete: adopt, onCompleteParams: [target, answering]});
            for (var i:int = 0; i < queue.length; i++) {
                TweenLite.to(queue[i], time, {y: queueY(i)});
            }
        }

        private function adopt(target:DisplayObjectContainer,
                answering:DisplayObject):void
        {
            answering.x -= target.x;
            answering.y -= target.y;
            target.addChild(answering);
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
            main.input.addChild(point);
            return point;
        }

        internal function update():int
        {
            if (main.keyMouse.justPressed(bindings.landfill)) {
                answer("landfill");
            }
            else if (main.keyMouse.justPressed(bindings.recycle)) {
                answer("recycle");
            }
            else if (main.keyMouse.justPressed("MOUSE")) {
                var name:String = main.keyMouse.target.name;
                if (name in itemClasses) {
                    answer(name);
                }
            }
            var winning:int = model.update(countdown.remaining);
            splice(model.queueMax);
            return winning;
        }

        private function populateSwap():void
        {
            if (!("landfill" in buttonXs)) {
                buttonXs["landfill"] = main.input.landfill.x;
                buttonXs["recycle"] = main.input.recycle.x;
            }
            bindings.landfill = "LEFT";
            bindings.recycle = "RIGHT";
            buttonXs["landfill"] = -1 * Math.abs(buttonXs["landfill"]);
            buttonXs["recycle"] = Math.abs(buttonXs["recycle"]);
            main.input.landfill.x = buttonXs["landfill"];
            main.input.recycle.x = buttonXs["recycle"];
            updateSwap(0.0);
        }

        private function updateSwap(swapTime:Number=0.1):Boolean
        {
            bindings.landfill = model.swapped ? "RIGHT" : "LEFT";
            bindings.recycle = model.swapped ? "LEFT" : "RIGHT";
            if (model.justSwapped) {
                buttonXs["landfill"] *= -1;
                buttonXs["recycle"] *= -1;
                TweenLite.to(main.input.landfill, swapTime, 
                    {x: buttonXs["landfill"]});
                TweenLite.to(main.input.recycle, swapTime, 
                    {x: buttonXs["recycle"]});
                return true;
            }
            return false;
        }

        private function splice(max:int):void
        {
            remove(queue.splice(max, int.MAX_VALUE));
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
