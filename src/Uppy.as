package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;

	public class Uppy extends Sprite
	{
		private var uploadFiles:Object = {};
		private var callbackName:String;
		private var singleFile:Boolean;
		
		private var files:FileReferenceList = new FileReferenceList()
		private var buttonCursorSprite:Sprite;
		
		public function Uppy()
		{
			Security.allowDomain("*");	// Allow uploading to any domain

			var params:Object = root.loaderInfo.parameters || {};
			singleFile = !!params.singleFile;
			callbackName = params.callbackName;
			
			wireMouseEvents();

			createButton();

			function onFileSelect(fileReference:FileReference):void {
				var f:FileReferenceHolder = new FileReferenceHolder(fileReference);
				uploadFiles[f.getId()] = f;
				var result:* = ExternalInterface.call(callbackName, "select", f.getInfo());
			};
			
			files.addEventListener(Event.SELECT, function():void {
				for (var i:Number = 0; i < files.fileList.length; i++) {
					onFileSelect(files.fileList[i]);
				}
			});
			
			this.stage.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				if (singleFile) {
					var ref:FileReference = new FileReference();
					ref.addEventListener(Event.SELECT, function():void {
						onFileSelect(ref);
					});
					ref.browse();
				} else {
					files.browse();
				}
			});
			
			ExternalInterface.addCallback('cancel', function(fileId:String):void {
				var uploadFile:FileReferenceHolder = uploadFiles[fileId];
				var fileRef:FileReference = uploadFile.getFileReference();
				fileRef.cancel();
			});
			
			ExternalInterface.addCallback('upload', function(fileId:String, config:Object):void {
				try {
					var uploadFile:FileReferenceHolder = uploadFiles[fileId];
					wireFileEvents(uploadFile);

					var fileRef:FileReference = uploadFile.getFileReference();
					var request:URLRequest = new URLRequest();
					
					request.url = config.url || '?';
					request.method = config.method || URLRequestMethod.POST;
					
					var data:Object = config.data || {};
					var post:URLVariables = new URLVariables();
					var key:String;
					for (key in data) {
						post[key] = data[key];
					}
					request.data = post;
					
					fileRef.upload(request, config.fileParamName, false);
				} catch (e:*) {
					log(e);
				}
			});
		}
		
		private function wireFileEvents(uploadFile:FileReferenceHolder):void {
			
			function fileListener(event:Event):void {
				ExternalInterface.call(callbackName, event.type.toLowerCase(), uploadFile.getInfo(), event);
			}
			
			var events:Array = [
				DataEvent.UPLOAD_COMPLETE_DATA,
				HTTPStatusEvent.HTTP_STATUS,
				IOErrorEvent.IO_ERROR,
				ProgressEvent.PROGRESS,
				SecurityErrorEvent.SECURITY_ERROR,
				Event.ACTIVATE,
				Event.CANCEL,
				Event.COMPLETE,
				Event.DEACTIVATE,
				Event.OPEN,
				Event.SELECT
			];
			
			var fileRef:FileReference = uploadFile.getFileReference();
			for each (var eventName:String in events) {
				fileRef.addEventListener(eventName, fileListener);
			}
		}
		
		private function wireMouseEvents():void {
			function mouseListener(event:MouseEvent):void {
				ExternalInterface.call(callbackName, event.type.toLowerCase());
			}
			var events:Array = [
				MouseEvent.MOUSE_OVER, 
				MouseEvent.MOUSE_OUT, 
				MouseEvent.MOUSE_DOWN, 
				MouseEvent.MOUSE_UP
			];
			
			for each(var eventName:String in events) {
				this.stage.addEventListener(eventName, mouseListener);
			}
		}
		
		private function log(message:*):void {
			ExternalInterface.call(callbackName, "log", message);
		}
		
		private function createButton():void {
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;			
			
			var buttonCursorSprite:Sprite = new Sprite();
			buttonCursorSprite.graphics.beginFill(0xFFFFFF, 0);
			buttonCursorSprite.graphics.drawRect(0, 0, 1000, 1000);
			buttonCursorSprite.buttonMode = true;
			buttonCursorSprite.useHandCursor = true;
				
			this.stage.addChild(buttonCursorSprite);
			this.stage.invalidate();
		}
		
	}
	

}
