WITH bcls
        AS (SELECT cfv_id,
                         mlt_id,
                         clf_id,
                         cls_id,
                         1-CONNECT_BY_ISLEAF parent,
                         status,
                         name,
                         code,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
                         code_key,
                         clv_clf_id,
                         clv_cls_id,
                         CONNECT_BY_ISLEAF list,
                         LEVEL top_level
                 FROM clv
                 WHERE status <> 2
                 START WITH cfv_id = :cfv_id
                     AND mlt_id = :mlt_id
                     AND clf_id in (:clf_id, :inclf_id)
                     AND cls_id = :cls_id
                 CONNECT BY PRIOR cfv_id = cfv_id
                     AND PRIOR mlt_id = mlt_id
                     AND PRIOR clf_id = clv_clf_id
                     AND PRIOR cls_id = clv_cls_id),
    zcls
        AS (SELECT *
                FROM (SELECT DISTINCT
                                   cls.mlt_id,
                                   cls.clf_id,
                                   cls.cls_id,
                                   cls.code,
                                   cls.name,
                                   CONNECT_BY_ROOT (cls.cls_id) root_cls,
                                   CONNECT_BY_ROOT (cls.clf_id) root_clf,
                                   LEVEL lev
                            FROM cls
                            WHERE mlt_id = :mlt_id
                            START WITH mlt_id = :mlt_id 
                                AND clf_id = :clf_id
                                AND EXISTS (SELECT 1
                       FROM  bcls
                       WHERE bcls.list = 1
                            AND bcls.mlt_id = cls.mlt_id
                            AND bcls.clf_id = cls.clf_id
                            AND bcls.cls_id = cls.cls_id)
                            CONNECT BY PRIOR mlt_id = mlt_id
                                AND PRIOR clf_id = clf_id
                                AND PRIOR cls_id = cls_cls_id) a
                WHERE gen_shbl_dvs_sgn(a.mlt_id,a.clf_id,a.cls_id,:prj_id,1) = gen_shbl_dvs_sgn(a.mlt_id,a.root_clf,a.root_cls,:prj_id,1)),
xcls
    AS (SELECT b.mlt_id,
                 NVL(z.clf_id, b.clf_id) AS clf_id,
                 NVL(z.cls_id, b.cls_id) AS cls_id,
                 b.clf_id AS clf_id_pp,
                 b.cls_id AS cls_id_pp,
                 b.code,
                 b.name,
                 b.parent
         FROM bcls b, zcls z
         WHERE b.mlt_id = z.mlt_id(+)
              AND b.clf_id = z.root_clf(+)
              AND b.cls_id = z.root_cls(+)),
zdvs 
    AS (select xcls.clf_id_pp,
                xcls.cls_id_pp,
                xcls.code cls_code,
                xcls.name cls_name,
                dvs.mlt_id,
                dvs.clf_id,
                dvs.cls_id,
                dvs.sgn_id,
                dvs.dvs_id,
                dvs.code,
                dvs.name,
                dvs.status 
         from xcls, dvs  
         where dvs.mlt_id = :mlt_id
           and dvs.mlt_id = xcls.mlt_id
           and dvs.clf_id = xcls.clf_id
           and dvs.cls_id = xcls.cls_id 
           and exists (select 1 
                       from nmpp
                       where dvs.mlt_id = nmpp.mlt_id
                         and dvs.clf_id = nmpp.clf_id
                         and dvs.cls_id = nmpp.cls_id
                         and nmpp.prj_id = :prj_id
                         and regexp_like(nmpp.sname||nmpp.fname,'{([^[{]*)\[&?'||dvs.dvs_id||'\]'))),
zvsn as (select distinct zdvs.mlt_id,
                         zdvs.clf_id_pp,
                         zdvs.cls_id_pp,
                         zdvs.code,
                         zdvs.name, 
                         zdvs.clf_id,
                         zdvs.cls_id,
                         zdvs.dvs_id,
                         zdvs.sgn_id,
                         vso.vsn_id,
                         :prj_id prj_id
        from zdvs, vds, vso
        where zdvs.mlt_id = vds.mlt_id
          and zdvs.clf_id = vds.clf_id
          and zdvs.cls_id = vds.cls_id
          and zdvs.sgn_id = vds.sgn_id
          and zdvs.dvs_id = vds.dvs_id
          and vds.mlt_id = vso.mlt_id
          and vds.clf_id = vso.clf_id
          and vds.cls_id = vso.cls_id
          and vds.sgn_id = vso.sgn_id
          and vds.dvs_id = vso.dvs_id
          and vds.vsn_id = vso.vsn_id
          and zdvs.clf_id = :inclf_id
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)
       UNION ALL 
       select distinct zdvs.mlt_id,
                         zdvs.clf_id_pp,
                         zdvs.cls_id_pp,
                         zdvs.code,
                         zdvs.name, 
                         zdvs.clf_id,
                         zdvs.cls_id,
                         zdvs.dvs_id,
                         zdvs.sgn_id,
                         vso.vsn_id,
                         :prj_id prj_id
        from zdvs, vds, vso
        where zdvs.mlt_id = vds.mlt_id
          and zdvs.clf_id = vds.clf_id
          and zdvs.cls_id = vds.cls_id
          and zdvs.sgn_id = vds.sgn_id
          and zdvs.dvs_id = vds.dvs_id
          and vds.mlt_id = vso.mlt_id
          and vds.clf_id = vso.clf_id
          and vds.cls_id = vso.cls_id
          and vds.sgn_id = vso.sgn_id
          and vds.dvs_id = vso.dvs_id
          and vds.vsn_id = vso.vsn_id
          and zdvs.clf_id = :clf_id
          and not exists (select 1 
                          from ocl 
                          where vso.mlt_id = ocl.mlt_id
                            and ocl.clf_id = :inclf_id
                            and vso.obj_id = ocl.obj_id)
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)),
endval as
(select zdvs.mlt_id,
       zdvs.clf_id_pp,
       zdvs.cls_id_pp,
       zdvs.code,
       zdvs.name, 
       zdvs.clf_id,
       zdvs.cls_id,
       zdvs.dvs_id,
       zdvs.sgn_id,
       zdvs.vsn_id,
       prj_id,
       SP_ACCEPTOR.return_values(zdvs.mlt_id, zdvs.clf_id, zdvs.cls_id, zdvs.prj_id, zdvs.dvs_id, zdvs.sgn_id, zdvs.vsn_id,1) sval,
       SP_ACCEPTOR.return_values(zdvs.mlt_id, zdvs.clf_id, zdvs.cls_id, zdvs.prj_id, zdvs.dvs_id, zdvs.sgn_id, zdvs.vsn_id,0) val
from  zvsn zdvs),
unq as
(SELECT sdv.cfv_id,
       sdv.mlt_id,
       sdv.clf_id,
       sdv.cls_id,
       c.code code_cl,
       c.name name_cl,
       obj.obj_id, 
       obj.name name_ob,
       oclp.sname,
       oclp.fname,
       sdv.sgn_id,
       sdv.dvs_id,
       a.vsn_id,
       nmpp.prj_id,
       sdv.code,
       sdv.name sdvname,
       a.val val,
       a.sval sval,
       sdv.ord ord
FROM bcls c, endval a, sdv, dvs, nmpp, obj, ocl, vso, oclp
where c.mlt_id = a.mlt_id
  and c.clf_id = a.clf_id_pp
  and c.cls_id = a.cls_id_pp
  and sdv.mlt_id = c.mlt_id
  and sdv.clf_id = c.clf_id
  and sdv.cls_id = c.cls_id
  and sdv.cfv_id = c.cfv_id
  and sdv.mlt_id = dvs.mlt_id
  and sdv.clf_id = dvs.clf_id
  and sdv.cls_id = dvs.cls_id
  and sdv.sgn_id = dvs.sgn_id
  and sdv.dvs_id = dvs.dvs_id
  and dvs.sgn_id = a.sgn_id
  and dvs.name = a.name
  and sdv.mlt_id = nmpp.mlt_id
  and sdv.clf_id = nmpp.clf_id
  and sdv.cls_id = nmpp.cls_id
  and nmpp.prj_id = :prj_id
  and REGEXP_LIKE (nmpp.sname || nmpp.fname, '\[&?' || sdv.dvs_id || '\]')
  and obj.mlt_id = ocl.mlt_id
  and obj.obj_id = ocl.obj_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and vso.mlt_id = a.mlt_id
  and vso.clf_id = a.clf_id
  and vso.cls_id = a.cls_id
  and vso.dvs_id = a.dvs_id
  and vso.sgn_id = a.sgn_id
  and vso.vsn_id = a.vsn_id
  and obj.prj_id = :prj_id
  and obj.status = 1
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.fname not like '%?%'
  and (ocl.clf_id = :inclf_id or (ocl.clf_id = :clf_id and not exists (select 1 
                          from ocl 
                          where vso.mlt_id = ocl.mlt_id
                            and ocl.clf_id = :inclf_id
                            and vso.obj_id = ocl.obj_id))))
  
select distinct *
from (select distinct mlt_id,
                      cfv_id,
                      clf_id,
                      cls_id,
                      obj_id,
                      name_ob "Наименование историческое",
                      code_cl "Код класса",
                      name_cl "Класс", 
                      code, 
                      val,
                      sname "Наименования краткое",
                      fname "Наименования полное"
      from unq)
pivot ( max(val)
for (code) in (:DVSFIELDS:)
)
order by 1