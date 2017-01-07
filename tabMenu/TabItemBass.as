package tabMenu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;


	public class TabItemBass extends MovieClip
	{
		protected var _group:String,
					_bg:MovieClip,
					_name:String,
					_defaultTabe:String,
					_selected:Boolean;
					
		private var _timerId:uint;	
		
		public function TabItemBass(GroupName_p:String=null)
		{
			super();
			_group = GroupName_p
			_bg = Obj.get('bg',this)
			
			_name = this.name.split('_')[0]
			try
			{			
				this.gotoAndStop(_name)	
			}
			catch(e:Error)
			{
				trace('<<<Frame label '+_name+' not found in scene '+_name+'.>>>')
			}
			_defaultTabe = this.name.split('_')[1]	
			TabMenuManager.event.addEventListener(TabMenuEvent.SELECT,onSelected)	
			if(_defaultTabe!=null && _defaultTabe.toLowerCase()=='true')
			{
				_timerId = setTimeout(sendEventBytimer,5)
			}
			this.addEventListener(MouseEvent.CLICK,click_fun)	
		}
		
		private function sendEventBytimer():void
		{
			
			sendEvent()
			clearTimeout(_timerId)
		}
		
		/** defined active tab selected metod or add _true of end name tabe simple 'tabname_true' if add true this tab is default selected tab*/
		public function setup():void
		{
			sendEvent()
		}
		
		protected function onSelected(event:TabMenuEvent):void
		{
			
			if(event.group == _group)
			{
				if(event.name == _name && _bg!=null)
				{
					_selected = true
				}
				else if(_bg!=null)
				{
					_selected = false
				}
				if(_bg!=null)
				{		
					_bg.gotoAndStop(_selected)
				}
			}
		}
		
		protected function click_fun(event:MouseEvent):void
		{
			
			if(!_selected)
			{			
				sendEvent()
			}
		}
		protected function sendEvent():void
		{
			TabMenuManager.event.dispatchEvent(new TabMenuEvent(TabMenuEvent.SELECT,_group,_name))
		}
	}
}