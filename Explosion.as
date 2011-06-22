package
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public final class Explosion extends Shape
	{
		private static const R: Number = 1.0;
		private static const R_MAX: Number = 20.0;
		private static const GROWTH: Number = 1.6;
		private static const DECAY: Number = 0.95;
		
		private var smoke: Boolean;
		private var smoked: Boolean = false;
		private var rMax: Number;
		private var growth: Number;
		private var decay: Number;
		private var r: Number;
		
		private static var _p: Point = new Point( 0, 0 );
		public static function get p(): Point
		{
			return _p;
		}
		
		public function Explosion( x: Number = 0.0, y: Number = 0.0, smoke: Boolean = true, 
			rMax: Number = R_MAX, growth: Number = GROWTH, decay: Number = DECAY, setPoint: Boolean = false )
		{
			this.x = x;
			this.y = y;
			this.smoke = smoke;
			this.rMax = rMax;
			this.growth = growth;
			this.decay = decay;
			this.r = R;
			
			if ( setPoint )
				_p = new Point( x, y );
			
			filters = [ new BlurFilter( 10, 10 ), new GlowFilter( 0xFFFFFF, 1, 10, 10 ) ];
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
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
			if ( r < rMax ) {
				r *= growth;
				graphics.clear();
				graphics.beginFill( 0xffff00 ); //0xF5A90A //255 << 16 | 255 << 8 | 255 * aI );
				graphics.drawCircle( 0, 0, r );
				graphics.endFill();
			} else {  
				visible = false;
				main.instance.removeChild( this );
			}
			
			if ( r * 2 > rMax ) {
				if ( smoke ) {
					smoked = true;
					Smoke.invoke( x - 10, y + 10, rMax, 0.96, rMax / 5 );
					//Smoke.invoke( x - 10, y - 10, rMax, 0.96, rMax / 5 );
					Smoke.invoke( x + 10, y + 20, rMax, 0.96, rMax / 5 );
					//Smoke.invoke( x + 10, y + 20, rMax, 0.96, rMax / 5 );
					Smoke.invoke( x, y, rMax + 0, 0.99, ( rMax + 0 ) / 5 );
				}
			}
		}
	}
}