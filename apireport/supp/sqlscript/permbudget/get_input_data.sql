select rec.record_id, 
	   rec.record_number, 
	   rec.record_title, 
	   rec.record_desc, 
	   usr.user_name, 
	   usr.user_lastname,
	   usr.user_patronymic,
	   rec.date_create,
	   SUBSTRING(CAST(record_desc AS VARCHAR(2000)), CHARINDEX(CAST('Заявитель' AS VARCHAR(9)), CAST( record_desc AS VARCHAR(2000))) + 9, DataLength(record_desc) - CHARINDEX(CAST('Заявитель' AS VARCHAR(9)), CAST( record_desc AS VARCHAR(2000))) - 8) initiator,
	   CONVERT(VARCHAR(16),rec.date_create , 103) date_start,
	   CONVERT(VARCHAR(16),rec.date_finish , 103) date_finish,
	   cRecordType.recordtype_name recordtype_name,
	   cPriority.priority_name,
	   rec.record_queue keyword
from cRecords rec 
		join eUsers usr ON (rec.creator_id = usr.user_id) 
		join cRecordType ON (rec.recordtype_id = cRecordType.recordtype_id)
		join cPriority ON (rec.priority_id = cPriority.priority_id)
where rec.record_id > 3898
  and rec.system_id = 27
  and cRecordType.recordtype_id = 117
  and rec.date_create between CONVERT(DATETIME, ? , 104) AND CONVERT(DATETIME, ? , 104)