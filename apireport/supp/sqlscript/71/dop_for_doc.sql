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
  and clv.clf_id in (:clf_id, :inclf_id)
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id),
zcls
as (select   distinct
           cls.mlt_id,
           cls.clf_id,
           cls.cls_id,
           cls.code,
           cls.name,
           connect_by_root (cls.cls_id) root_cls,
           connect_by_root (cls.clf_id) root_clf,
           level lev
    from   cls
    where   cls.mlt_id = 1
    start with   cls.mlt_id = 1
               and (cls.mlt_id, cls.clf_id, cls.cls_id) in
                      (select   bcls.mlt_id, bcls.clf_id, bcls.cls_id
                         from   bcls
                        where   bcls.list = 1
                                and bcls.mlt_id =
                                       cls.mlt_id
                                and bcls.clf_id =
                                       cls.clf_id
                                and bcls.cls_id =
                                       cls.cls_id)
  connect by       prior mlt_id = mlt_id
               and prior clf_id = clf_id
               and prior cls_id = cls_cls_id),                                                    
xcls
as (select   b.mlt_id,
             nvl (z.clf_id, b.clf_id) as clf_id,
             nvl (z.cls_id, b.cls_id) as cls_id,
             b.clf_id as clf_id_pp,
             b.cls_id as cls_id_pp,
             b.code,
             b.name,
             b.list,
             b.prj_id
      from   bcls b, zcls z
     where       b.mlt_id = z.mlt_id(+)
             and b.clf_id = z.root_clf(+)
             and b.cls_id = z.root_cls(+))
             
SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, cas.name name_at
, clsb.code code_at
, clsb.name znach_at
, :prj_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (348,345)
AND xcls.mlt_id = carb.mlt_id
AND xcls.clf_id = carb.clf_id
AND xcls.cls_id = carb.cls_id 
AND carb.ass_mlt_id = clsb.mlt_id 
AND carb.ass_clf_id = clsb.clf_id 
AND carb.ass_cls_id = clsb.cls_id 
AND cas.cas_id = carb.cas_id
AND cas.mlt_id = carb.mlt_id
AND cas.clf_id = carb.clf_id
AND carb.ass_mlt_id = cas.ass_mlt_id
AND carb.ass_clf_id = cas.ass_clf_id

union all

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, cas.name name_at
, clsb.code code_at
, clsb.name znach_at
, :prj_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (347,344)
AND xcls.mlt_id = carb.mlt_id
AND xcls.clf_id = carb.clf_id
AND xcls.cls_id = carb.cls_id
AND carb.ass_mlt_id = clsb.mlt_id 
AND carb.ass_clf_id = clsb.clf_id 
AND carb.ass_cls_id = clsb.cls_id 
AND cas.cas_id = carb.cas_id
AND cas.mlt_id = carb.mlt_id
AND cas.clf_id = carb.clf_id
AND carb.ass_mlt_id = cas.ass_mlt_id
AND carb.ass_clf_id = cas.ass_clf_id

union all

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, cas.name name_at
, clsb.code code_at
, clsb.name znach_at
, :prj_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (346,343)
AND xcls.mlt_id = carb.mlt_id
AND xcls.clf_id = carb.clf_id
AND xcls.cls_id = carb.cls_id
AND carb.ass_mlt_id = clsb.mlt_id 
AND carb.ass_clf_id = clsb.clf_id 
AND carb.ass_cls_id = clsb.cls_id 
AND cas.cas_id = carb.cas_id
AND cas.mlt_id = carb.mlt_id
AND cas.clf_id = carb.clf_id
AND carb.ass_mlt_id = cas.ass_mlt_id
AND carb.ass_clf_id = cas.ass_clf_id

order by 4, 6