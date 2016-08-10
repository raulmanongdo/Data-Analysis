/*
Special timesheeeet has no clients and are expense accounts (5003).					
Normal  timesheet includes expenses for OPEX and Connect and may use named account 'Staff Development'.					
*/					
					
with CTE as					
	(				
	select				
		tim.RecordTypeID			
		,program__c			
		,case when (tim.RecordTypeID = '01290000000mwB1AAI' and 			
			IsNull(con.lastName,'NULL') not like '%Staff Development%'  and  		
			IsNull(con.lastName,'NULL') not like '%Mr. Dummy%')  		
			then 'Billable' else 'Non-Billable' end as Bill_NonBill_Ind		
		,case when (tim.RecordTypeID = '01290000000mwB1AAI' and			
			IsNull(con.lastName,'NULL') not like '%Staff Development%'  and		
			IsNull(con.lastName,'NULL') not like '%Mr. Dummy%')  		
			then tim.BillableHour__c else cast(tim.Duration__c  as float) end as Bill_NonBill_Hours		
		 ,datefromparts (datepart(year,tim.CreatedDate), datepart(month,tim.CreatedDate),1) as CreateMonth			
		 ,case when tim.recordtypeid = '01290000000mwB2AAI' then			
				case 	
					when tim.SpecialTimeSheetType__c in ('Add Time','On Call') then 'OPEX'
					when tim.SpecialTimeSheetType__c  Is Null then 'OPEX'
					when tim.SpecialTimeSheetType__c  like 'Make Up%' then 'Make up'
					else tim.SpecialTimeSheetType__c
					end
				end as OverHeadType	
			,case 		
				when con.RegionName__c like 'NSW-N%' or emp.RegionName__c like 'NSW-N%' 	
					or con_ad.RegionName__c like 'NSW-N%' then'NSW-North'
				when con.RegionName__c like 'NSW-C%' or emp.RegionName__c like 'NSW-C%' 	
					or con_ad.RegionName__c like 'NSW-C%' then'NSW-Coast'
				when con.RegionName__c like 'NSW-W%' or emp.RegionName__c like 'NSW-W%' 	
					or con_ad.RegionName__c like 'NSW-W%' then'NSW-West' 
				when pr.Name like 'ACT%'  or emp.RegionName__c like 'ACT%' then 'ACT'	
				when pr.Name like 'VIC%'  or emp.RegionName__c like 'VIC%' then 'VIC'	
				when pr.Name like 'QLD%'  or emp.RegionName__c like 'QLD%' then 'QLD'	
				when pr.Name like 'WA%'   or emp.RegionName__c like 'WA%' then 'WA'	
				when pr.Name like 'SA%'   or emp.RegionName__c like 'SA%' then 'SA'	
				when pr.Name like 'TAS%'  or emp.RegionName__c like 'TAS%' then 'TAS'	
			end as 'State'		
		,case 			
			when pr.Name like '%Disability%' then 'Disability' 		
			when pr.Name like '%Health%'  then 'Health' 		
			when pr.Name like '%NDIS%'then 'NDIS' 		
			when pr.Name like '%Transpac%' then 'Transpac'		
			when pr.Name like '%TAC%' then 'TAC'		
			when pr.Name like '%Private%' then 'Private'		
			when pr.Name like '%OPEX%' then 'OPEX'		
			when pr.Name like '%CHSP%' or pr.Name like  '%CCSP%' or pr.Name like '%NRCP%' then 'CHSP'		
			when pr.Name like '%comm%' or pr.Name like '%Ambula%' or  pr.Name like '%NDA%' or pr.Name like '%Attendant%' then 'Commercial'		
			when pr.Name like '%Connect%' then 'Connect'		
			when pr.Name like '%HCP%' then 'HCP'		
		end as program			
	from 				
		Timesheet__c tim			
		left join [Employee__c] emp on  tim.Employee__c = emp.id			
		left join ClientProgramEnrolment__c cpe on tim.ClientProgramEnrolment__c = cpe.Id			
		left join Program__c pr on  cpe.Program__c = pr.ID			
		left join Contact con on cpe.contact__c = con.Id			
		left join [Address__c] con_ad on con.address__c =  con_ad.id			
	where 				
		tim.createddate between cast('2016-01-01' as date) and cast('2016-04-30' as date) and			
		timesheetstatus__c = 'Invoice & Pay Completed' and			
		IsNull(con.lastName,'NULL') not like '%Dummy%')			
SELECT 					
	IsNull(cte.[State], 'NSW') as [State]				
	,cte.program				
	,cTE.CreateMonth				
	,cte.Bill_NonBill_Ind as Bill_NonBill_Indicator				
	,case when cte.program = 'Connect' then 'Training' else cte.OverHeadType end as OverHeadType				
	,sum(cte.Bill_NonBill_Hours) as Hours				
FROM CTE					
group by 					
	cte.[State], cte.Bill_NonBill_Ind, cte.CreateMonth, cte.program, cte.OverHeadType				
