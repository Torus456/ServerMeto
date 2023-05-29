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
, 'Текстовый' tip
, '3' num_id
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
, 'Текстовый' tip
, '2' num_id
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
, 'Текстовый' tip
, '1' num_id
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

union all

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, (case when a.name_at is null then 'Статья бюджета'
       else a.name_at end) name_at
, a.code_at
, (case when a.znach_at is null then 'Не определено'
       else a.znach_at end) znach_at
, :prj_id
, 'Текстовый' tip
, '5' num_id
FROM xcls, (SELECT    carb.mlt_id
                    , carb.clf_id
                    , carb.cls_id
                    , cas.name name_at
                    , clsb.code code_at
                    , clsb.name znach_at
                    FROM car carb, cls clsb, cas
                    WHERE carb.cas_id in (359, 358)
                    AND carb.ass_mlt_id = clsb.mlt_id 
                    AND carb.ass_clf_id = clsb.clf_id 
                    AND carb.ass_cls_id = clsb.cls_id 
                    AND cas.cas_id = carb.cas_id 
                    AND cas.mlt_id = carb.mlt_id
                    AND cas.clf_id = carb.clf_id
                    AND carb.ass_mlt_id = cas.ass_mlt_id
                    AND carb.ass_clf_id = cas.ass_clf_id) a
where xcls.mlt_id = a.mlt_id (+)
  AND xcls.clf_id = a.clf_id (+)
  AND xcls.cls_id = a.cls_id (+)
  AND xcls.list = 1
  
union all

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, (case when a.name_at is null then 'Направление инвестиций'
       else a.name_at end) name_at
, a.code_at
, (case when a.znach_at is null then 'Не определено'
       else a.znach_at end) znach_at
, :prj_id
, 'Текстовый' tip
, '6' num_id
FROM xcls, (SELECT    carb.mlt_id
                    , carb.clf_id
                    , carb.cls_id
                    , cas.name name_at
                    , clsb.code code_at
                    , clsb.name znach_at
                    FROM car carb, cls clsb, cas
                    WHERE carb.cas_id in (361, 360)
                    AND carb.ass_mlt_id = clsb.mlt_id 
                    AND carb.ass_clf_id = clsb.clf_id 
                    AND carb.ass_cls_id = clsb.cls_id 
                    AND cas.cas_id = carb.cas_id 
                    AND cas.mlt_id = carb.mlt_id
                    AND cas.clf_id = carb.clf_id
                    AND carb.ass_mlt_id = cas.ass_mlt_id
                    AND carb.ass_clf_id = cas.ass_clf_id) a
where xcls.mlt_id = a.mlt_id (+)
  AND xcls.clf_id = a.clf_id (+)
  AND xcls.cls_id = a.cls_id (+)
  AND xcls.list = 1
  
union all

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, cas.name name_at
, clsb.code code_at
, (case when clsb.name = 'Нет' then 'Да'
       else clsb.name end) znach_at
, :prj_id
, 'Текстовый' tip
, '7' num_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (351, 352)
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
and (xcls.code like '01%' or clsb.name = 'Да')

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
, 'Текстовый' tip
, '8' num_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (349, 355)
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
, 'Текстовый' tip
, '9' num
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (350)
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
AND xcls.code like '99%'

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
, 'Текстовый' tip
, '4' num_id
FROM xcls, car carb, cls clsb, cas
WHERE carb.cas_id in (354, 353)
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
AND xcls.code not like '99%'

order by 4, 11, 8