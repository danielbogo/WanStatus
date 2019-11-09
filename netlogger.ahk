on_notification  := false
end_notification := false
siren_counter    := 0

;statuslogger("your wan ip here") ; public
statuslogger("your private ip here")  ; private

^p:: end_notification := true ; end the warning anytime by pressing ctrl + p




statuslogger(URL)
{
	global on_notifications
	global end_notification
	global siren_counter
	
	while(true)
	{
		if(on_notifications)
		{
			if(end_notification)
			{
				end_notification := false
				on_notifications := false
				siren_counter    := 0
			}
			
			else
			{
				if(!notify(siren_counter))
				{
					on_notifications := false
					siren_counter    := 0
				}
			}
		}
		
		else
		{
			sleep, 120000 ;sleep 2 minutes
			on_notifications := wanPinger(URL,1000)
		}
	}
}

wanPinger(URL,timeout = 1000)
{
	_fail_count     := 0
	_max_fail_count := 4
	_counter        := 0
	_warn_flag      := false
	
	while(_counter < 4)
	{
		Runwait,%comspec% /c ping -w %timeout% %url%>_wan_log,,hide 
		fileread , StrTemp, _wan_log
		
		if(RegExMatch(StrTemp, "Destination host unreachable", result))
		{
			_warn_flag := true
			break
		}
		
		if(RegExMatch(StrTemp, "Lost = 4", result))
		{
			++_fail_count
		}
		
		++_counter
	}
	
	if(_fail_count == _max_fail_count && _warn_flag == false)
	{
		_warn_flag := true
	}
	
	if(_warn_flag)
	{
		FormatTime, time,,
		FileAppend, %time%`r`n, _errorEntries,
	}
	
	return _warn_flag
}

notify(ByRef counter)
{
	soundPlay,  %A_WorkingDir%/media/siren.mp3, WAIT
	++counter
	
	if(counter == 100)
		return false
	else
	{
		sleep, 2000
		return true
	}
}