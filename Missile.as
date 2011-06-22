package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public class Missile extends Shape
	{
		private static var _active: Boolean = false;
		public static function get active(): Boolean
		{
			return _active;
		}
		private var dest: Sprite;
		private var ratioX: Number;	
		private var ratioY: Number;
		private var pn: Point;
		private var p: Point;
		
		public static const AMMO: uint = 20;
		private static var _ammo: uint = AMMO;
		public static function set ammo( n: uint ): void
		{
			_active = false;
			_ammo = n;
		}
		public static function get ammo(): uint
		{
			return _ammo;
		}
		private static var speedMax: Number = 9.50;
		private static var speedMin: Number = 1.00;
		private static var speedAccel: Number = 0.08;
		private var _speed: Number = 0.0;
		private function get speed(): Number
		{
			if ( _speed < speedMax )
				_speed += speedAccel;

			return _speed;
		}
		
		private var colider: Asteroid;
		private var coliders: Vector.<Asteroid> = new Vector.<Asteroid>;
		
		private static const S_INX: uint = 1;
		private var smokeInx: uint = S_INX;
		
		private static var stack: Array = [];
		
		public function Missile()
		{
			this.dest = main.player;
			_active = true;
			_ammo--;
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
		}
		
		private function addedToStageHandler( e: Event ): void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			
			pn = new Point( main.instance.mouseX, main.instance.mouseY );
			p = new Point( x, y );
			x = dest.x;
			y = dest.y;
			
			rotation = dest.getChildAt(0).rotation; 
				
			ratioX = Math.sin( rotation * Math.PI / 180 );
			ratioY = Math.cos( rotation * Math.PI / 180 );

			x -= ratioX;
			y += ratioY;
			
			filters = [ new GlowFilter( 0xAAAA00,1.0, 5, 5 ) ];
			
			graphics.beginFill( 0xFF0000 );
            graphics.lineStyle( 2, 0xFF0000 );
			graphics.moveTo( -5, -10 );
			graphics.lineTo( 5, -10 );
			graphics.lineTo( 0, 10 );
			graphics.lineTo( -5, -10 );

			addEventListener( Event.ENTER_FRAME, onEnterFrameHandler, false, 0, true );
		}
		
		private function removedFromStageHandler( e: Event ): void
		{
			if ( _ammo > 0 )
				_active = false;
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
			p.x = x;
			p.y = y;
			return Point.distance( p, o.p ) <= width / 2 + o.r ? true : false;
		}
		
		private function onEnterFrameHandler( e: Event ): void
		{
			if ( x < 0 || y < 0 || x > nanoPHAGE.w || y > nanoPHAGE.h ) {
				main.instance.removeChild( this );
			} else {
				if ( hasColided() ) {
					visible = false;
					colider.damage = 50;
					Asteroid.rocketed = colider;
					main.instance.addChild( new Explosion( x, y, true, 22, 1.90, 0.95, true ) );
					main.instance.addChild( new Explosion( x + 20, y, true, 22, 1.90 ) );
					main.instance.addChild( new Explosion( x, y + 25, true, 22, 1.90 ) );
					main.instance.addChild( new Explosion( x - 10, y -20, true, 22, 1.90 ) );
					main.instance.removeChild( this );
				} else {
					
					if ( smokeInx == 0 ) {
						Smoke.invoke( x, y, 18, 0.970 );
						smokeInx = S_INX;
					}
					
					var degrees: Number = Math.atan2( main.instance.mouseY - y, main.instance.mouseX - x ) * 180 / Math.PI - 90;

					rotation += ( 180 / Math.PI ) * Math.atan2( 
						( 
							Math.cos( rotation * Math.PI / 180 ) * Math.sin( degrees * Math.PI / 180 ) 
							- Math.sin( rotation * Math.PI / 180 ) * Math.cos( degrees * Math.PI / 180 )
						), (
							Math.sin( rotation * Math.PI / 180 ) * Math.sin( degrees * Math.PI / 180 ) 
							+ Math.cos( rotation * Math.PI / 180 ) * Math.cos( degrees * Math.PI / 180 ) 
						)
					) / 15;

					ratioX = Math.sin( rotation * Math.PI / 180 );
					ratioY = Math.cos( rotation * Math.PI / 180 );
					
					x -= speed * ratioX; 
					y += speed * ratioY;
					
					smokeInx--; 
				}
			}
		}
	}
}