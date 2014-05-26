package com.finegamedesign.templeofgold
{
    import flash.utils.getTimer;
    import flash.events.Event;
    import flash.text.TextField;
    
    /**
     * Text field displays minutes and seconds remaining.
     */
    public class Countdown
    {
        public var remaining:int;
        public var startTime:int;
        public var started:Boolean;
        public var txt:TextField;
        private var millisecondsPerSecond:int = 1000;
        private var _seconds:int = int.MIN_VALUE;

        public function get seconds():int
        {
            return _seconds;
        }

        public function set seconds(value:int):void
        {
            _seconds = value;
            display(value);
        }

        public function setup(seconds:int, time_txt:TextField, startNow:Boolean=false):void
        {
            this.seconds = seconds;
            this.txt = time_txt;
            if (startNow) {
                start();
            }
            else {
                display(seconds);
            }
        }

        public function start():void
        {
            if (!started) {
                started = true;
                this.startTime = getTimer();
                this.txt.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            }
        }

        public function stop():void
        {
            if (started) {
                started = false;
                if (0 < seconds) {
                    seconds -= (getTimer() - startTime) / millisecondsPerSecond;
                }
                this.txt.removeEventListener(Event.ENTER_FRAME, update);
            }
        }

        /**
         * getTimer prevents drift that Timer.EVENT can have.
         * http://www.computus.org/journal/?p=25
         */
        public function update(e:Event = null):void
        {
            var elapsed:int = getTimer() - startTime;
            remaining = Math.ceil(seconds - (elapsed / millisecondsPerSecond));
            display(remaining);
        }

        public function display(remaining:int):void
        {
            if (remaining <= 0) {
                stop();
                remaining = 0;
            }
            this.remaining = remaining;
            if (null != txt) {
                var secondsPerMinute:int = 60;
                var minutes:String = int(remaining / secondsPerMinute).toString();
                var seconds:String = int(remaining % secondsPerMinute).toString();
                if (seconds.length <= 1) {
                    seconds = "0" + seconds;
                }
                txt.text = minutes + ":" + seconds;
            }
        }
    }
}
