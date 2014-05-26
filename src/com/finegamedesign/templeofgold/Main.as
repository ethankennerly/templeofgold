package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.text.TextField;
    import flash.utils.getTimer;

    import org.flixel.system.input.KeyMouse;
    import org.flixel.plugin.photonstorm.API.FlxKongregate;
    // import com.newgrounds.API;

    public dynamic class Main extends MovieClip
    {
        [Embed(source="../../../../sfx/chime.mp3")]
        private static var selectClass:Class;
        internal var select:Sound = new selectClass();
        [Embed(source="../../../../sfx/die.mp3")]
        private static var wrongClass:Class;
        internal var wrong:Sound = new wrongClass();
        [Embed(source="../../../../sfx/getPearl2.mp3")]
        private static var correctClass:Class;
        internal var correct:Sound = new correctClass();
        [Embed(source="../../../../sfx/wavesloop.mp3")]
        private static var loopClass:Class;
        internal var loop:Sound = new loopClass();

        private var loopChannel:SoundChannel;

        public var feedback:MovieClip;
        public var levelScore_txt:TextField;
        public var score_txt:TextField;
        public var time_txt:TextField;
        public var restartTrial_btn:SimpleButton;
        public var input:MovieClip;
        public var head:DisplayObjectContainer;

        internal var keyMouse:KeyMouse;
        private var inTrial:Boolean;
        private var level:int;
        private var maxLevel:int;
        private var model:Model;
        private var view:View;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }
        
        public function init(event:Event=null):void
        {
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            inTrial = false;
            level = 1;
            LevelSelect.onSelect = load;
            LevelLoader.onLoaded = trial;
            reset();
            model = new Model();
            view = new View();
            updateHudText();
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            restartTrial_btn.addEventListener(MouseEvent.CLICK, restartTrial, false, 0, true);
            // API.connect(root, "", "");
        }

        private function restartTrial(e:MouseEvent):void
        {
            reset();
            next();
        }

        public function load(level:int):void
        {
            this.level = level;
            LevelLoader.load(level);
            select.play();
            gotoAndPlay("level");
            loopChannel = loop.play(0, int.MAX_VALUE);
        }

        public function trial():void
        {
            inTrial = true;
            mouseChildren = true;
            model.populate(level);
            view.populate(model, this);
        }

        internal function answer(correct:Boolean, pointClip:PointClip):void
        {
            input.answer.mouseChildren = false;
            input.answer.mouseEnabled = false;
            input.addChild(input.answer);
            input.answer.x = pointClip.x;
            input.answer.y = pointClip.y;
            if (correct) {
                this.correct.play();
                input.answer.gotoAndPlay("correct");
            }
            else {
                this.wrong.play();
                input.answer.gotoAndPlay("wrong");
            }
        }

        private function updateHudText():void
        {
            // trace("updateHudText: ", score, highScore);
            score_txt.text = Model.score.toString();
            if (model) {
                levelScore_txt.text = model.levelScore.toString();
            }
            // score_txt.text = "12";
            // highScore_txt.text = Model.highScore.toString();
            // level_txt.text = level.toString();
            // maxLevel_txt.text = maxLevel.toString();
        }

        private function update(event:Event):void
        {
            var now:int = getTimer();
            keyMouse.update();
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
            if (inTrial) {
                result(view.update());
            }
            else {
                // view.update();
                if ("next" == feedback.currentLabel) {
                    next();
                }
            }
            updateHudText();
        }

        private function result(winning:int):void
        {
            if (!inTrial) {
                return;
            }
            if (winning <= -1) {
                lose();
            }
            else if (1 <= winning) {
                win();
            }
        }

        private function win():void
        {
            reset();
            level++;
            if (maxLevel < level) {
                // level = 0;
            }
            else {
            }
            feedback.gotoAndPlay("correct");
            correct.play();
            FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        private function reset():void
        {
            inTrial = false;
            if (null != loopChannel) {
                loopChannel.stop();
            }
        }

        private function lose():void
        {
            reset();
            FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
            wrong.play();
        }

        public function next():void
        {
            // feedback.gotoAndPlay("none");
            mouseChildren = true;
            restart();
        }

        public function restart():void
        {
            if (view) {
                view.clear();
            }
            mouseChildren = true;
            gotoAndPlay(1);
        }
    }
}
