package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flash.utils.Timer;

	public class Asteroid extends Bitmap
	{
		public static const UNTOUCH: uint = 90;
		
		public var unTouchable: uint = 0;
		public var rott: Number;	
		
		public var ratioX: Number;	
		public var ratioY: Number;
		private var pX: Number;
		private var pY: Number;
		private var t: Timer;
		private var dp: Number;
		
		private var _p: Point;
		public function get p(): Point
		{
			return _p;
		}
		
		public var r: Number;
		public var dead: Boolean = false;
		public var colided: uint = 0;
		public var colidedMain: Boolean = false;
		public var cRot: Number;
		
		public static var rocketed: Asteroid = null;
		
		public static var speedMax: Number = 4.5; 
		private static var speedMin: Number = 1.5;
		private static var speedAccel: Number = 0.1;
		private static var speedDecay: Number = 0.99;
		
		private static var i: uint = 0;
		
		private var _speed: Number = 0.0;
		private function get speed(): Number
		{
			if ( _speed < speedMax && !dead )
				_speed += speedAccel;
			if ( _speed > speedMax && !dead )
				_speed *= speedDecay;
			return _speed;
		}
		public function set setSpeed( s: Number ): void
		{
			_speed = s;
		}
		
		private var _lifeHit: uint = 3;
		private var _lifeR: int;
		private var _life: int = 0;
		public function set damage( v: int ): void
		{
			if ( _life > 0 )
				_life -= v;
			transform.colorTransform = new ColorTransform( _lifeR / _life, 1, _lifeR / _life * 0.4 );
		}
		
		public function Asteroid( pX: Number = NaN, pY: Number = NaN, r: Number = 40.0, s: Number = 0.5 )
		{
			name = 'A'+ i.toString();
			
			this.pX = pX;
			this.pY = pY;
			this.r = r;
			
			_life = int( r + 0.5 ) * 2;
			_lifeR = _life;
			_p = new Point( x + r + 10, y + r + 10 );
			i++;
			
			// SET RANDOM MOVEMENT
			setRotationTimer();
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
		}
		
		private function timerCompleteHandler( e: Event ): void
		{
			t.stop();
			
			if ( unTouchable <= 0 ) {
				rott = -180 * Math.random() + 180 * Math.random(); 
				ratioX = Math.sin( rott * Math.PI / 180 );
				ratioY = Math.cos( rott * Math.PI / 180 );	
			}

			if ( !dead ) {
				setRotationTimer();
			}
		}
		
		private function setRotationTimer(): void
		{
			if ( t == null ) {
				t = new Timer( 4000 * Math.random() + 2000, 1 );
				t.addEventListener( TimerEvent.TIMER_COMPLETE, timerCompleteHandler, false, 0, true );
			}
			t.start();
		}
		
		private function addedToStageHandler( e: Event ): void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			
			x = !isNaN( pX ) ? pX : parent.width * Math.random();
			y = !isNaN( pY ) ? pY : parent.height * Math.random();
			
			rott = -180 * Math.random() + 180 * Math.random();

			ratioX = Math.sin( rott * Math.PI / 180 );
			ratioY = Math.cos( rott * Math.PI / 180 );

			var tmpS: Shape = new Shape();
			tmpS.filters = [ new BlurFilter( 5, 5 ), new GlowFilter( 0xAAFF00, 1, 12, 12, 3 ) ];
			tmpS.graphics.beginFill( 0x0000FF );
			tmpS.graphics.drawCircle( 0, 0, r - 4 );
			tmpS.alpha = 0.8;

			for ( var i: uint = 0; i < 16; i++ ) {
				
				tmpS.graphics.beginFill( ( int( ( Math.random() + 0.5 ) * 255 ) << 16 ) | ( 0 << 8 ) | 255 );
				tmpS.graphics.drawCircle ( 
					( -r + 5.0 ) * Math.random() + ( r - 5.0 ) * Math.random(), 
					( -r + 5.0 ) * Math.random() + ( r - 5.0 ) * Math.random(), 
					Math.random() * 10 
				);
			}
			tmpS.graphics.endFill(); 
			var tmpBMD: BitmapData = new BitmapData( r * 2 + 20, r * 2 + 20, true, 0x000000 );
			var tmpMTX: Matrix = new Matrix();
			tmpMTX.translate( r + 10, r + 10 );
			tmpBMD.draw( tmpS, tmpMTX );
			bitmapData = tmpBMD;
			tmpS = null;
			tmpBMD = null;
			tmpMTX = null;

			addEventListener( Event.ENTER_FRAME, onEnterFrameHandler, false, 0, true );
		}
		
		private function removedFromStageHandler( e: Event ): void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			removeEventListener( Event.ENTER_FRAME, onEnterFrameHandler );
			if ( t is Timer )
				t.removeEventListener( TimerEvent.TIMER_COMPLETE, timerCompleteHandler );
		}

		public function coll(): void
		{
			colided = 3;
			blendMode = BlendMode.INVERT;
			_speed = speedMin;
			rott = cRot;
			ratioX = Math.sin( rott * Math.PI / 180 );
			ratioY = Math.cos( rott * Math.PI / 180 );
		}
		
		private function onEnterFrameHandler( e: Event ): void
		{
			if ( !dead ) {
				
				if ( _life <= 0 ) {
				
					main.instance.setChildIndex( this, 1 );
					main.aCount--;
					dead = true;
					blendMode = BlendMode.HARDLIGHT;
					speedMin = 0.5;
					filters = [ new BlurFilter() ];
					transform.colorTransform = new ColorTransform( 1,  1, 0.5 );
				} else {
				
					if ( colidedMain )
						blendMode = BlendMode.DIFFERENCE;
					else if ( colided > 0 )
						colided--; 
					else
						blendMode = BlendMode.NORMAL;
						
					this.dp = width * 0.5 + 20;// + 5;
					if ( x - dp > nanoPHAGE.w )
						x = 0 - dp;
					if ( y - dp > nanoPHAGE.h )
						y = 0 - dp;
						
					if ( x < 0 - dp )
						x = nanoPHAGE.w + dp;
					if ( y < 0 - dp )
						y = nanoPHAGE.h + dp;
				}
			} else {
				_speed = speedMin;
				alpha *= 0.980;
			}
			
			if ( alpha < 0.1 )
				main.instance.removeChild( this );
			
			x -= speed * ratioX; 
			y += speed * ratioY; 
			
			// POINT MARKER
			_p.x = x + r + 10.0;
			_p.y = y + r + 10.0;
		}
	}
}