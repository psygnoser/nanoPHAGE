package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public class Projectile extends Shape
	{
		private var dest: Sprite;
		private var ratioX: Number;	
		private var ratioY: Number;
		private var speed: Number = 16.0;
		private var pn: Point;
		private var colider: Asteroid;
		private var coliders: Vector.<Asteroid> = new Vector.<Asteroid>;
		
		public function Projectile()
		{
			this.dest = main.player;

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
		}
		
		private function addedToStageHandler( e: Event ): void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			
			pn = new Point( x, y );
			
			x = dest.x;
			y = dest.y;
			rotation = dest.getChildAt(0).rotation;
			
			ratioX = Math.sin( rotation * Math.PI / 180 );
			ratioY = Math.cos( rotation * Math.PI / 180 );
			
			x -= 35.0 * ratioX;
			y += 35.0 * ratioY;
			
			filters = [ new GlowFilter( 0xFF0000, 0.8 ) ];
			
			graphics.beginFill( 0xFFFF00 );
            graphics.lineStyle( 1, 0x000000 );
			graphics.drawCircle( 0, 0, 5 );
			graphics.endFill();
			
			addEventListener( Event.ENTER_FRAME, onEnterFrameHandler, false, 0, true );
		}
		
		private function removedFromStageHandler( e: Event ): void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			removeEventListener( Event.ENTER_FRAME, onEnterFrameHandler );
		}
		
		private function hasColided(): Boolean
		{
			var asteroids: Vector.<Asteroid> = main.getAsteroids;
			var inx: int;
			var col: Boolean;
			for each ( var aS: Asteroid in asteroids ) {
				inx = coliders.indexOf( aS );
				col = colided( aS );
				if ( !aS.dead 
				&& inx == -1
				&& col ) { 
					coliders.push( aS );
					colider = aS;
					return true;
				} else if ( !col && inx != -1 ) {
					coliders.splice( inx, 1 );
				}	
			}
			return false;
		}
		
		private function colided( o: Asteroid ): Boolean 
		{
			pn.x = x;
			pn.y = y;
			return Point.distance( pn, o.p ) <= width * 0.5 + o.r ? true : false;
		}
		
		private function onEnterFrameHandler( e: Event ): void
		{
			if ( x < 0 || y < 0 || x > nanoPHAGE.w || y > nanoPHAGE.h ) {
				main.instance.removeChild( this );
			} else {
				if ( hasColided() ) {
					visible = false;
					colider.damage = 10;
					main.instance.removeChild( this );
					main.instance.addChild( new Explosion( x, y, false, 6, 2.2 ) );
				} else {
					x -= speed * ratioX; 
					y += speed * ratioY; 
				}
			}
		}
	}
}