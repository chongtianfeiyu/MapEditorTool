package application.mapEditor.ui
{
	import com.frameWork.gestures.Gestures;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import application.mapEditor.comps.MapCityNodeComp;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class DragScrollGestures extends Gestures implements IAnimatable
	{
		public var friction:Number = 0.9;
		
		public var minScale:Number = 0.3;	//可以缩放的最小值
		public var maxScale:Number = 1.5;	//可以缩放的最大值
		
		protected var _downPoint:Point = null;//点击在target的什么位置
		
		protected var _targetWidth:Number = NaN;
		protected var _targetHeight:Number = NaN;
		
		protected var _dragRect:Rectangle;//拖动范围
		protected var _isDrag:Boolean = false;
		
		private var dx:Number = 0;
		private var dy:Number = 0;
		
		private var paressTime:Number = 0;
		
		public static var CAN_DRAG:Boolean = true;
		
		public function DragScrollGestures(target:DisplayObject, callBack:Function=null) {
			super(target, callBack);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL,nativeStage_mouseWheelHandler,false,0,true);
		}
		
		/**
		 * pc上的滚轮测试 
		 * @param event
		 */		
		private function nativeStage_mouseWheelHandler(event:MouseEvent):void {
			var scale:Number = _target.scaleX + event.delta * 0.01;
			
			var fromLocal:Point = _target.globalToLocal(new Point(event.localX,event.localY));
			
			_target.pivotX = fromLocal.x;
			_target.pivotY = fromLocal.y;
			
			_target.scaleX = scale;
			_target.scaleY = scale;
			
			var toLocal:Point = _target.globalToLocal(new Point(Starling.current.nativeStage.mouseX,Starling.current.nativeStage.mouseY));
			var dx:int = toLocal.x - fromLocal.x;
			var dy:int = toLocal.y - fromLocal.y;
			
			_target.x += dx * scale;
			_target.y += dy * scale;
			
			checkTargetPosition();
			
			if(!isNaN(minScale)) {
				if(_target.scaleX < minScale) _target.scaleX = minScale;
				if(_target.scaleY < minScale) _target.scaleY = minScale;
			}
			
			if(!isNaN(maxScale)) {
				if(_target.scaleX > maxScale) _target.scaleX = maxScale;
				if(_target.scaleY > maxScale) _target.scaleY = maxScale;
			}
		}
		
		public override function checkGestures(touch:Touch):void{
			
			if(!CAN_DRAG) {
				dx = dy = 0;
				return;
			}
			
			if(touch.phase == TouchPhase.BEGAN){
				_downPoint = touch.getLocation(_target.stage);
				Starling.current.juggler.remove(this);
				paressTime = Starling.juggler.elapsedTime;
				dx = 0;
				dy = 0;
			}else if(touch.phase == TouchPhase.MOVED){
				var movePoint:Point = touch.getLocation(_target.stage);
				
				dx = movePoint.x - _downPoint.x;
				dy = movePoint.y - _downPoint.y;
				
				_target.x += dx;
				_target.y += dy;
				
				if(_dragRect) checkTargetPosition();
				if(_callBack) _callBack();
				
				_downPoint = movePoint;
				_isDrag = true;
			} else if(touch.phase == TouchPhase.ENDED) {
				
				Starling.juggler.add(this);
				
				var elpasedtime:Number = Starling.juggler.elapsedTime;
				dx = dx * Math.max(0,(0.8 - (elpasedtime - paressTime)) * 10);
				dy = dy * Math.max(0,(0.8 - (elpasedtime - paressTime)) * 10);
				
				_downPoint  = null;
				_isDrag = false;
			}
		}
		
		public function advanceTime(time:Number):void {
			
			var vx:Number = dx * friction;
			var vy:Number = dy * friction;
			
			_target.x += vx;
			_target.y += vy;
			
			dx = vx;
			dy = vy;
			
			if(_dragRect) checkTargetPosition();
			if(_callBack) _callBack();
			
			if(Math.abs(dx) <= 0.05 && Math.abs(dy) <= 0.05) {
				Starling.juggler.remove(this);
				_target.x = Math.round(_target.x);
				_target.y = Math.round(_target.y);
			}
		}
		
		protected function checkTargetPosition():void{
			if(_targetWidth * _target.scaleX > _dragRect.width){
				if((_target.x - _target.pivotX*_target.scaleX) > _dragRect.x) 
					_target.x = _target.pivotX*_target.scaleX + _dragRect.x;
				
				if((_target.x - _target.pivotX*_target.scaleX) < (_dragRect.width - _targetWidth*_target.scaleX - _dragRect.x)) 
					_target.x = (_dragRect.width - _targetWidth*_target.scaleX  - _dragRect.x) + (_target.pivotX*_target.scaleX);
			}else{
				if((_target.x - _target.pivotX*_target.scaleX) < _dragRect.x) 
					_target.x = _target.pivotX*_target.scaleX + _dragRect.x;
				
				if((_target.x - _target.pivotX*_target.scaleX) > (_dragRect.width - _targetWidth*_target.scaleX - _dragRect.x)) 
					_target.x = (_dragRect.width - _targetWidth*_target.scaleX  - _dragRect.x) + (_target.pivotX*_target.scaleX);
			}
			
			if(_targetHeight * _target.scaleY > _dragRect.height){
				if((_target.y - _target.pivotY*_target.scaleY) > _dragRect.y) 
					_target.y = _target.pivotY*_target.scaleY + _dragRect.y;
				
				if((_target.y - _target.pivotY*_target.scaleY) < (_dragRect.height - _targetHeight*_target.scaleY - _dragRect.y)) 
					_target.y = (_dragRect.height - _targetHeight*_target.scaleY - _dragRect.y) + (_target.pivotY*_target.scaleY);
			}else{
				if((_target.y - _target.pivotY*_target.scaleY) < _dragRect.y) 
					_target.y = _target.pivotY*_target.scaleY + _dragRect.y;
				
				if((_target.y - _target.pivotY*_target.scaleY) > (_dragRect.height - _targetHeight*_target.scaleY - _dragRect.y)) 
					_target.y = (_dragRect.height - _targetHeight*_target.scaleY - _dragRect.y) + (_target.pivotY*_target.scaleY);
			}
		}
		
		/**
		 * 设置拖动范围 
		 * @param dragRect		可视范围大小
		 * @param targetWidth	拖动对象的宽
		 * @param targetHeight	拖动对象的高
		 */		
		public function setDragRectangle(dragRect:Rectangle,targetWidth:Number,targetHeight:Number):void{
			_dragRect = dragRect;
			_targetWidth = targetWidth;
			_targetHeight = targetHeight;
		}
		
		public override function dispose():void {
			Starling.current.juggler.remove(this);
			super.dispose();
		}
	}
}