package
{
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public final class Smoke extends Shape
	{
		private static const R: Number = 5.0;
		private static const R_MAX: Number = 20.0;
		private static const GROWTH: Number = 1.07;
		private static const DECAY: Number = 0.98;
		
		private var gray: uint;
		
		private static var stack: Vector.<Smoke>;
		
		private var rMax: Number;
		private var decay: Number;
		private var growth: Number;
		private var r: Number;
		
		public function Smoke( singleton: SmokeSingleton )
		{
			filters = [ new BlurFilter( 15, 15 ) ];
			visible = false;
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
		}
		
		public static function init( n: uint ): void 
		{
			stack = new Vector.<Smoke>;
			
			while ( n-- ) {
				var s: Smoke = new Smoke( new SmokeSingleton );
				stack.push( s );
				main.instance.addChild( s );
			}
		}
		
		public static function invoke( x: Number, y: Number, rMax: Number = R_MAX, 
										decay: Number = DECAY, growth: Number = GROWTH ): Boolean
		{ 
			for each ( var smoke: Smoke in stack ) {
				if ( !smoke.visible ) {
					smoke.setup( x, y, rMax, decay, growth );
					return true;
				}	
			}
			
			var s: Smoke = new Smoke( new SmokeSingleton );
			s.setup( x, y, rMax, decay, growth );
			stack.push( s );
			return false;
		}
		
		private function setup( x: Number, y: Number, rMax: Number = R_MAX, 
								decay: Number = DECAY, growth: Number = GROWTH ): void
		{
			this.x = x;
			this.y = y;
			this.rMax = rMax;
			this.decay = decay;
			this.growth = growth;
			this.r = R;
			this.gray = 180;
			
			alpha = 0.8;
			visible = true;
			graphics.clear();
		}
		
		private function addedToStageHandler( e: Event ): void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
		}
		
		private function removedFromStageHandler( e: Event ): void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( e: Event ): void
		{
			if ( visible )
				if ( alpha > 0.1 ) {
					if ( r < rMax )
						r *= growth; 
					alpha *= decay;
					gray *= 0.95; 
					graphics.clear();
					graphics.beginFill( ( gray << 16 ) | ( gray << 8 ) | gray ); // 0x666666 );
					graphics.drawCircle( 0, 0, r );		
					graphics.endFill();
				} else {
					visible = false;
				}
		}
	}
}
// Singleton enforcer
class SmokeSingleton {}