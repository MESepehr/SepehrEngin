package net
{
	import com.mteamapp.StringFunctions;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	public class SaffronURLLoader extends EventDispatcher
	{
		private static const ln:String = '\r\n';
		private static const defaultPort:uint = 80;
		
		private var senderSocket:Socket ;

		private var rawBodyToSend:String;
		
		public var responsHeaders:Vector.<URLRequestHeader> = new Vector.<URLRequestHeader>();
		
		public function SaffronURLLoader()
		{
			super();
			senderSocket = new Socket();
			senderSocket.addEventListener(Event.CONNECT,onConnectedToSocket);
			senderSocket.addEventListener(IOErrorEvent.IO_ERROR,connectionError);
			senderSocket.addEventListener(ProgressEvent.SOCKET_DATA,serverAnswered);
		}
		
		public function load(request:URLRequest):void
		{
			if(senderSocket.connected)
			{
				senderSocket.close();
			}
			
			
			var currentDomain:String = StringFunctions.findMainDomain(request.url);
			var currentPort:int = StringFunctions.findPortOfURL(request.url) ;
			if(currentPort==-1)
			{
				currentPort = defaultPort ;
			}
			
			//Reset respond headers
			responsHeaders = new Vector.<URLRequestHeader>();
			
			//Create headers
			rawBodyToSend = request.method+' '+request.url+' HTTP/1.1'+ln +
				'Host: '+currentDomain+((currentPort==defaultPort)?'':':'+currentPort)+ln;
			for(var i:int = 0 ; i<request.requestHeaders.length ; i++)
			{
				var currentHeader:URLRequestHeader = request.requestHeaders[i] ;
				rawBodyToSend+=currentHeader.name+': '+currentHeader.value+ln;
			}
			if(request.contentType!=null)
				rawBodyToSend+="Content-Type: "+request.contentType+ln;
			//Body part
			if(request.data!=null)
			{
				rawBodyToSend+="content-length: "+String(request.data).length+ln
				rawBodyToSend+=ln;
				rawBodyToSend+=request.data.toString();
			}
			else
			{
				rawBodyToSend+=ln ;
			}
			
			trace("Connect to : "+currentDomain+":"+currentPort);
			senderSocket.connect(currentDomain,currentPort);
		}
		
		
		protected function serverAnswered(event:ProgressEvent):void
		{
			responsHeaders = new Vector.<URLRequestHeader>();
			
			var serverAnswerParts:Array = senderSocket.readUTFBytes(senderSocket.bytesAvailable).split(ln+ln) ;
			senderSocket.close();
			if(serverAnswerParts.length!=2)
			{
				trace("Respond problem!!");
				this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
			var headers:Array = serverAnswerParts[0].split(ln);
			for(var i:int = 0 ; i<headers.length ; i++)
			{
				var headInPart:Array = headers[i].split(':') ;
				if(headInPart.length==2)
				{
					trace(">>>header:"+headInPart);
					responsHeaders.push(new URLRequestHeader(headInPart[0],headInPart[1]));
				}
			}
			
			trace(">>>Body:"+serverAnswerParts[1]);
		}
		
		protected function connectionError(event:IOErrorEvent):void
		{
			trace("Server connection fails");
			this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		protected function onConnectedToSocket(event:Event):void
		{
			trace("Server connected, Send request : "+rawBodyToSend);
			senderSocket.writeUTFBytes(rawBodyToSend);
			senderSocket.flush();
		}
	}
}