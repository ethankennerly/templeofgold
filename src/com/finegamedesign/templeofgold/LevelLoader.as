package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;

    public class LevelLoader extends Sprite
    {
        internal static var levels:Array = [
            LevelInput,
            LevelTime,
            LevelIdentify,
            LevelSwap
        ];

        internal static var onLoaded:Function;

        internal static var instance:DisplayObjectContainer;

        internal static function load(level:int):DisplayObjectContainer
        {
            var levelClass:Class = Sprite;
            if (level <= levels.length) {
                levelClass = levels[level - 1];
            }
            instance = new levelClass();
            return instance;
        }

        /**
         * Disable selecting text.
         */
        public function LevelLoader() 
        {
            super();
            for (var c:int = numChildren - 1; 0 <= c; c--) {
                removeChildAt(c);
            }
            addChild(instance);
            this.mouseEnabled = false;
            this.mouseChildren = false;
            onLoaded();
        }
    }
}
