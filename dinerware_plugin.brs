 Function dinerware_Initialize(msgPort As Object, userVariables As Object, bsp as Object)

  print "dinerware_Initialize - entry"
  print "type of msgPort is ";type(msgPort)
  print "type of userVariables is ";type(userVariables)

  dw = {}
  dw.name="dinerware"
  dw.version=0.1
  dw.uv = userVariables
  dw.bsp = bsp
  dw.ProcessEvent=dinerware_process_event
  dw.mp = msgPort

  ' Create an array to hold roUrlTransferObject that are being used by the SOAP commands
  dw.xferObjects = createObject("roArray",0, true)

  dw.udpReceiverPort = 21000
  dw.udpReceiver = CreateObject("roDatagramReceiver", dw.udpReceiverPort)
  dw.udpReceiver.SetPort(msgPort)

	' Create a timer that updates the screen every 30 sec
	dw.timer=CreateObject("roTimer")
	dw.timer.SetPort(msgPort)
	dw.timer.SetDate(-1, -1, -1)
	dw.timer.SetTime(-1, -1, -1, 30)
	dw.timer.Start()

  dw.brainURL=getUserVar(userVariables,"brain_url")
  dw.brainURL=dw.brainURL+":84/VirtualClient"
  print "brain at: ";dw.brainURL

  return dw

End Function



Function dinerware_process_event(event as Object)
  retval = false

  print "dinerware_process_event - type of event is ";type(event)

  if type(event) = "roDatagramEvent" then
    retval = ParseDinerwareUDP(event, m)
  else if (type(event) = "roUrlEvent") then
    print "*****  Got roUrlEvent in Dinerware"  
    retval = HandleDinerwareXferEvent(event, m)
  else if type(event) = "roHttpEvent" then
    print "roHttp event received in Dinerware processing"
  else if type(event) = "roTimerEvent" then
	print "Got Timer event"
  end if
  return retval
end Function


Function ParseDinerwareUDP(origMsg as Object, dw as object) as boolean

  retval = false
  print "confirm obj: ";dw.name

  ' verify it is actually a UDP message'
  if type(origMsg) = "roDatagramEvent" then
    
    ' convert the message to all lower case for easier string matching later
    msg = lcase(origMsg)
    print "Received UDP message: "+msg

    ' dinerware!getmenu'

    r = CreateObject("roRegex", "^dinerware", "i")
    match=r.IsMatch(msg)
    if match then
      print "*** dinerware ***"
      retval = true
      ' split the string
      r2 = CreateObject("roRegex", "!", "i")
      fields=r2.split(msg)
      print fields
      numFields = fields.count()
      if numFields<>2 then
        print "Incorrect number of fields for command:";msg
        return retval
      else 
        command=fields[1]
        print "command: ";command
      end if

      if command="getmenu" then
        'print "&&&&&&&&&&&&&&&&&&&&& getmenu &&&&&&&&&&&&&&&&&&&&&&&&&&"
        xfer = dwGetMenu(dw) 
        dw.xferObjects.push(xfer)
        retval=true
      end if
    end if
  end if
  return retval
end Function


sub dwGetMenu(dw as object) as object

  print "dwGetMenu"
  print " - type of mp: ";type(dw.mp)

  soapTransfer = CreateObject("roUrlTransfer")
  soapTransfer.SetMinimumTransferRate( 500, 1 )
  soapTransfer.SetPort( dw.mp )

  soapTransfer.SetUrl(dw.brainURL)
  ok = soapTransfer.addHeader("SOAPACTION", "http://tempuri.org/IVirtualClient/GetAllMenuItems")
  if not ok then
    stop
  end if
  ok = soapTransfer.addHeader("Content-Type", "text/xml; charset="+ chr(34) + "utf-8" + chr(34))
  if not ok then
    stop
  end if

  dwReqData=CreateObject("roAssociativeArray")
  dwReqData["type"]="GetAllMenuItems"
  soapTransfer.SetUserData(dwReqData)

  q=chr(34)
  x="<soapenv:Envelope xmlns:soapenv="+q+"http://schemas.xmlsoap.org/soap/envelope/"+q+" xmlns:tem="+q+"http://tempuri.org/"+q+">"
  x=x+"<soapenv:Header/><soapenv:Body><tem:GetAllMenuItems><!--Optional:--><tem:sSortOrder>?</tem:sSortOrder></tem:GetAllMenuItems></soapenv:Body></soapenv:Envelope>"

''  print "x=";x

  ok = soapTransfer.AsyncPostFromString(x)
  if not ok then
    stop
  end if

  return soapTransfer
end sub


Function HandleDinerwareXferEvent(msg as object, dw as object) as boolean
  
  eventID = msg.GetSourceIdentity()
  eventCode = msg.GetResponseCode()

  print "HandleDinerwareXferEvent ";msg

  found = false
  numXfers = dw.xferObjects.count()
  i = 0

  while (not found) and (i < numXfers)

    if dw.xferObjects[i]<>invalid
        id = dw.xferObjects[i].GetIdentity()
    else 
        goto loop_again
    end if
    dwReqData=dw.xferObjects[i].GetUserData()

    if (id = eventID) then
      ' See if this is the transfer being complete
      if (dwReqData <> invalid) then 
        reqData=dwReqData["type"]
      else
        reqData = ""
      end if
      if (msg.getInt() = 1) then
        print "Http transfer code: "; eventCode; " request type: ";reqData;
        if (eventCode = 200) then 
          if reqData="GetAllMenuItems" then
            print "reply to GetAllMenuItems"
            parseAllMenuReply(msg,dw)
            dw.xferObjects.Delete(i)
          end if
        end if    
      end if
    end if 
    loop_again:
    i=i+1 
  end while
end Function

Function parseAllMenuReply(menu as string,dw as object)
	retVal = false
	r=CreateObject("roXMLElement")
	b=r.Parse(menu)

	newMenu=[]

	if b <> false then
		retVal = true
		vals=r.GetNamedElements("s:Body")
		for each x in vals.GetChildElements()
			for each q in x.GetChildElements()
				for each a in q.GetChildElements()
					active = true
					item=""
					price=""
					desc=""
					'print "---------------------------------------"
					for each e in a.GetChildElements()
						name=e.GetName()
						body=e.GetText()

						if name="a:Active" then
							if body="false" then 
								active = false
								exit for
							end if
						else if name="a:ItemName" then
							'print "   ItemName: [";body;"]"
							item=body
						else if name="a:DisplayPrice" then
							'print "   DisplayPrice: [";body;"]"
							price=body
						else if name="a:MenuDescription" then
							'print "   MenuDescription: [";body;"]"
							desc=body
						end if
					next 'e'

					if (active) then
						ni=newMenuItem(item,price,desc)
						newMenu.push(ni)
					end if
				next 'a'
			next 'q'
		next 'x'

    n=getUserVar(m.uv,"numPresentationMenuItems")
    numPresentationMenuItems=val(n)
		print "Number of menu items = ";newMenu.count()
		for i = 1 to numPresentationMenuItems

			b = newMenu[i-1]

			val=str(i).trim()
			itemString ="item"+val+"_name"
			priceString ="item"+val+"_price"
			descString ="item"+val+"_desc"

			if b <> invalid then
				point=instr(1,b.price,".")
				priceStr="$"
				if point > 0 then
					priceStr=priceStr+mid(b.price,1,point+2)
				else
					priceStr=priceStr+b.price
				end if
				updateUserVar(dw.uv,itemString,b.item)
				print itemString;":";b.item
				updateUserVar(dw.uv,priceString,priceStr)
				print priceString;":";priceStr
				updateUserVar(dw.uv,descString,b.desc)
				print descString;":";b.desc
			else
				updateUserVar(dw.uv,itemString," ")
				'print itemString;":"
				updateUserVar(dw.uv,priceString," ")
				'print priceString;":"
				updateUserVar(dw.uv,descString," ")
				'print descString;":"
			end if		
		end for

  		' userVariablesChanged = CreateObject("roAssociativeArray")
		' userVariablesChanged["EventType"] = "USER_VARIABLES_UPDATED"
		' dw.mp.PostMessage(userVariablesChanged)
	end if

  return retVal
end Function



Function newMenuItem(item as string, price as string, desc as string) as object

  mi={}
  mi.item=item
  mi.price=price
  mi.desc=desc

  return mi
end Function

'sub updateUserVar(uv as object, targetVar as string, newValue as string)
''  print "updating "+targetVar+": "+newValue
''  if (uv[targetVar] <> invalid) then
''    uv[targetVar].currentValue$=newValue
''  end if
'end sub


sub updateUserVar(uv as object, targetVar as string, newValue as string)
  if newValue=invalid
      print "updateUserVar: new value for ";targetVar;" is invalid"
      return
  end if
  if targetVar=invalid
      print "updateUserVar: targetVar is invalid"
      return
  end if

  if uv[targetVar] <> invalid then
    if uv[targetVar].currentValue$ <> invalid then
      'print "updating "+targetVar+": "+newValue
      uv[targetVar].currentValue$=newValue
    end if
  else
      print "updateUserVar: error trying to set non-existant user variable ";targetVar
  end if
end sub

function getUserVar(uv as object, targetVar as string) as String

    if targetVar=invalid
        print "updateUserVar: targetVar is invalid"
        return ""
    end if

    if uv[targetVar] <> invalid then
      if uv[targetVar].currentValue$ <> invalid then
          return uv[targetVar].currentValue$
      end if
    else
        print "updateUserVar: error trying to set non-existant user variable ";targetVar
    end if

    return ""
end function
