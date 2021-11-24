with bcls as 
(select clv.mlt_id,
       clv.clf_id,
       clv.cls_id,
       clv.clv_clf_id,
       clv.clv_cls_id,
       clv.name,
       clv.code,
       clv.cfv_id,
       prj.prj_id,
       prj.name project_name,
       level clv_lev, 
       connect_by_isleaf list
from clv, cfv, prj
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id)
select distinct
	   bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.clv_clf_id,
       bcls.clv_cls_id,
       bcls.name,
       bcls.code,
       bcls.cfv_id,
       bcls.project_name,
       bcls.clv_lev,
       cls.code okved_code,
       cls.name okved_name,
       :prj_id prj_id
from bcls, car, cls
where bcls.mlt_id = car.mlt_id 
  and bcls.clf_id = car.clf_id 
  and bcls.cls_id = car.cls_id
  and bcls.list = 1
  and car.cas_id in (328, 325)
  and car.ass_mlt_id = cls.mlt_id
  and car.ass_clf_id = cls.clf_id
  and car.ass_cls_id = cls.cls_id
order by code,okved_code