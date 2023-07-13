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

select q.mlt_id, 
       q.clf_id, 
       q.cls_id,
       q.code,
       q.name,
       q.obj_id,
       q.sname,
       q.EI  
from (select a.mlt_id, 
       a.clf_id, 
       a.cls_id,
       a.code,
       a.name,
       a.obj_id,
       a.sname,
       a.EI,
       row_number() over(partition BY a.code ORDER BY a.code, a.obj_id) num            
from (select distinct xcls.mlt_id, 
       xcls.clf_id_pp clf_id, 
       xcls.cls_id_pp cls_id,
       xcls.code,
       xcls.name,
       obj.obj_id,
       oclp.sname,
       NVL ((SELECT
               CODE
            FROM
                OUM c, UMS u
            WHERE
                c.UMS_ID = u.UMS_ID
                AND c.mlt_id = obj.mlt_id
                AND c.obj_id = obj.obj_id
                AND ocl.CLS_ID = xcls.CLS_ID
                AND c.PRJ_ID = 72
                and c.cst_id = 559),                  
           (SELECT
                max(CODE)
            FROM
                CUM c, UMS u
            WHERE c.mlt_id = obj.mlt_id
                  AND c.clf_id = xcls.clf_id_pp
                  AND c.cls_id = xcls.cls_id_pp
                  AND c.ums_id = u.ums_id
                  AND c.prj_id = 72
                  and c.status <> 2
                  AND c.cst_id = 559)) EI
from xcls, ocl, obj, oclp
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1  
  and obj.prj_id = :prj_id
  and ocl.clf_id = :inclf_id
  and xcls.prj_id = obj.prj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.sname not like '%?%'
  and oclp.prj_id = xcls.prj_id
union all
select distinct xcls.mlt_id, 
       xcls.clf_id_pp clf_id, 
       xcls.cls_id_pp cls_id,
       xcls.code,
       xcls.name,
       obj.obj_id,
       oclp.sname,
       NVL ((SELECT
               CODE
            FROM
                OUM c, UMS u
            WHERE
                c.UMS_ID = u.UMS_ID
                AND c.mlt_id = obj.mlt_id
                AND c.obj_id = obj.obj_id
                AND ocl.CLS_ID = xcls.CLS_ID
                AND c.PRJ_ID = 72
                and c.cst_id = 559),                  
           (SELECT
                max(CODE)
            FROM
                CUM c, UMS u
            WHERE c.mlt_id = obj.mlt_id
                  AND c.clf_id = xcls.clf_id_pp
                  AND c.cls_id = xcls.cls_id_pp
                  AND c.ums_id = u.ums_id
                  AND c.prj_id = 72
                  and c.status <> 2
                  AND c.cst_id = 559)) EI
from xcls, ocl, obj, oclp
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1
  and obj.prj_id = :prj_id
  and ocl.clf_id = 6
  and not exists (select 1
                  from ocl oclin
                  where ocl.mlt_id = oclin.mlt_id
                    and ocl.obj_id = oclin.obj_id
                    and oclin.clf_id = :inclf_id)
  and xcls.prj_id = obj.prj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.prj_id = xcls.prj_id
  and oclp.sname not like '%?%') a) q
where q.num = 1
  
order by code, sname