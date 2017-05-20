if today lost < 10 than 
	AllowPlaceLongOrder=AllowPlaceLongOrder and true
	 AllowPlaceShortOrder = AllowPlaceShortOrder and true
else
	AllowPlaceLongOrder=AllowPlaceLongOrder and false
	AllowPlaceShortOrder= AllowPlaceShortOrder and false
endif

if index>77 and KDJ <-30 and 预付款比例<1500 than
	if AllowPlaceLongOrder and 已经挂的单子数量<1
		call placeorder(buy limit at bid-2pips, tp=100pips, sl=100) 时间10分钟
		send alarm message
	else
		send alarm message	
	endif
endif

if index>55 and KDJ <-30 and 预付款比例<2500 than
	if AllowPlaceLongOrder and 已经挂的单子数量<2
		call placeorder(buy limit at bid-2pips, tp=100pips, sl=100)
	else
		send alarm message	
	endif
endif

如果placetime 大于15分钟 且价格离开15点 则删除
