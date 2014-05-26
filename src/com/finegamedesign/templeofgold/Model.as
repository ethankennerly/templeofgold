package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Model
    {
        internal static var levelScores:Array = [];
        internal static var score:int = 0;
        internal static var seconds:int = 30;

        internal static var values:Object = {
            landfill: {landfill: 1, recycle: -1},
            recycle: {landfill: -1, recycle: 1},
            AluminumCan: {landfill: -8, recycle: 8},
            PlasticBottle: {landfill: -1, recycle: 1},
            Styrofoam: {landfill: 2, recycle: -2},
            PlasticBag: {landfill: 7, recycle: -7}
        }

        internal static var decks:Array = [
            ["landfill", "recycle", "recycle", "landfill", "recycle", "landfill"],
            ["AluminumCan", "PlasticBottle", "Styrofoam", "PlasticBag",
             "AluminumCan", "PlasticBottle", "Styrofoam", "PlasticBag",
             "AluminumCan", "PlasticBottle", "Styrofoam", "PlasticBag"]
        ]

        internal static var levels:Array = [
            {deck: 0, deckCount: 2, filters: 1, swaps: 0},
            {deck: 0, deckCount: 20, filters: 1, swaps: 0},
            {deck: 1, deckCount: 20, filters: 1, swaps: 0},
            {deck: 1, deckCount: 20, filters: 4, swaps: 0},
            {deck: 1, deckCount: 20, filters: 4, swaps: 3}
        ];

        public static function shuffle(array:Array):void
        {
            for (var i:int = array.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var tmp:* = array[i];
                array[i] = array[j];
                array[j] = tmp;
            }
        }

        internal var filters:int;
        internal var queueMax:int;
        internal var highScore:int;
        internal var queue:Array;
        internal var point:int = 0;
        internal var level:int;
        internal var levelScore:int;
        internal var swapped:Boolean = false;
        internal var justSwapped:Boolean = false;
        private var correctCount:int;
        private var secondsRemaining:int;
        private var swapCount:int;
        private var swaps:Array = [20, 15, 10];

        public function Model()
        {
            score = 0;
            highScore = 0;
            levelScores = [];
        }

        internal function populate(level:int):void
        {
            this.level = level;
            if (null == levelScores[level]) {
                levelScores[level] = 0;
            }
            levelScore = 0;
            correctCount = 0;
            var params:Object = levels[level - 1];
            filters = params.filters;
            populateSwap(params["swaps"]);
            secondsRemaining = int.MAX_VALUE;
            queueMax = int.MAX_VALUE;
            queue = [];
            for (var i:int = 0; i < params.deckCount; i++) {
                var deck:Array = decks[params.deck].concat();
                shuffle(deck);
                queue = queue.concat(deck);
            }
        }

        internal function clear():void
        {
        }

        internal function timed():Boolean
        {
            return 2 <= level;
        }

        internal function update(secondsRemaining:int):int
        {
            this.secondsRemaining = secondsRemaining;
            justSwapped = false;
            splice();
            return win();
        }

        private function populateSwap(swapCount:int):void
        {
            this.swapCount = swapCount;
            swapped = Math.random() * 2 < 0.5;
            justSwapped = swapped;
            swaps = [];
            if (swapCount) {
                for (var i:Number = swapCount - 0.5; 0 <= i; i -= 1.0) {
                    var swapTime:int = int(seconds * i / swapCount);
                    swapTime += int(Math.random() * 3) - 1;
                    swaps.push(swapTime);
                }
            }
        }

        private function updateSwap():void
        {
            if (secondsRemaining <= swaps[0]) {
                trace("Model.updateSwap: justSwapped");
                justSwapped = true;
                swaps.shift();
                swapped = !swapped;
            }
        }

        internal function splice():void
        {
            var speed:Number = correctCount 
                / Math.max(1.0, seconds - secondsRemaining);
            if (secondsRemaining <= 6) {
                queueMax = Math.max(10, speed * secondsRemaining);
            }
            else {
                queueMax = int.MAX_VALUE;
            }
            if (queueMax < queue.length) {
                trace("Model.update: splicing " + queue.length + " to " + queueMax);
                queue.splice(queueMax, int.MAX_VALUE);
            }
        }

        /**
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            updateScore();
            var winning:int = 0;
            if (queue.length == 0 || secondsRemaining <= 0) {
                winning = 1 <= levelScore ? 1 : -1;
            }
            return winning;
        }

        private function updateScore():int
        {
            if (levelScores[level] < levelScore) {
                levelScores[level] = levelScore;
            }
            var sum:int = 0;
            for each (var n:int in levelScores) {
                sum += n;
            }
            score = sum;
            return sum;
        }
       
        /**
         * To avoid hesitating to answer, swap after answer.
         */
        internal function answer(name:String):Boolean
        {
            point = values[queue[0]][name] * filters;
            point = int(point * Math.max(1, swapCount - 1));
            levelScore += point;
            queue.shift();
            var correct:Boolean = 0 <= point;
            if (correct) {
                correctCount++;
            }
            updateSwap();
            return correct;
        }
    }
}
