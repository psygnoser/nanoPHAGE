package 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="30")]
	
	/**
	 * nanoPHAGE
	 * @version 1.0 Beta 3.5
	 * @since 201006251704
	 * @author Tilen Leban <psygnoser@gmail.com>
	 * @link http://www.psywerx.net
	 */
	public class nanoPHAGE extends Sprite
	{
		public static const VERSION: String = '1.0 Beta 3.5';

		[Embed(source="img/logoSplash.jpg")] 
		private static var bg: Class;
		
		[Embed(source="img/nanophage.jpg")] 
		private static var nbg: Class;
		
		private static var _instance: nanoPHAGE;
		public static function get instance(): nanoPHAGE
		{
			return _instance;
		}
		
		private static var _w: Number;
		public static function get w(): Number
		{
			return _w;
		}
		
		private static var _h: Number;
		public static function get h(): Number
		{
			return _h;
		}
		
		public function nanoPHAGE()
		{
			_instance = this;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_w = stage.stageWidth;;
			_h = stage.stageHeight;
			
			var bgBMP: Sprite = new Sprite;
			var mbg: DisplayObject = new bg;
			mbg.alpha = 0.0;
			bgBMP.addChild( mbg );
			addChild( bgBMP );
			
			var bgT: Timer = new Timer( 40, 100 );
			bgT.start();
			bgT.addEventListener( TimerEvent.TIMER, function ( e: TimerEvent ): void { 
				mbg.alpha += 0.025;
			} );
			
			bgT.addEventListener( TimerEvent.TIMER_COMPLETE, function ( e: TimerEvent ): void { 
				mbg.alpha = 0.0;
				var npbg: DisplayObject = new nbg;
				npbg.alpha = 0.0;
				bgBMP.addChild( npbg );
				
				var bgT1: Timer = new Timer( 40, 50 );
				bgT1.start();
				bgT1.addEventListener( TimerEvent.TIMER, function ( e: TimerEvent ): void { 
					npbg.alpha += 0.025;
				} );
				bgT1.addEventListener( TimerEvent.TIMER_COMPLETE, function ( e: TimerEvent ): void {  
					bgBMP.addEventListener( MouseEvent.CLICK, init, false, 0, true );
				} );
			} );	
		}
		
		private function init( e: Event ): void
		{
			removeChildAt( _instance.numChildren - 1 );
			addChild( new main() );
		}
		
		public static function respawn(): void
		{
			_instance.removeChildAt( _instance.numChildren - 1 );
			var tmp: main = new main();
			_instance.addChild( tmp );
			tmp.stage.stageFocusRect = false;
			tmp.stage.focus = tmp;
		}
	}
}
