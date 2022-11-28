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
                     AND clf_id = :clf_id
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
                            WHERE mlt_id = 1
                            START WITH mlt_id = 1 
                                AND clf_id IN (6,3530)
                                AND EXISTS (SELECT 1
                       FROM  bcls
                       WHERE bcls.list = 1
                            AND bcls.mlt_id = cls.mlt_id
                            AND bcls.clf_id = cls.clf_id
                            AND bcls.cls_id = cls.cls_id)
                            CONNECT BY PRIOR mlt_id = mlt_id
                                AND PRIOR clf_id = clf_id
                                AND PRIOR cls_id = cls_cls_id) a
                WHERE gen_shbl_dvs_sgn(a.mlt_id,a.clf_id,a.cls_id,67,1) = gen_shbl_dvs_sgn(a.mlt_id,a.root_clf,a.root_cls,67,1)),
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
xobj as (select c.mlt_id,
       c.clf_id, 
       c.cls_id,
       c.code,
       c.name name_cls,
       obj.obj_id,
       oclp.sname,
       oclp.fname,
       sdv.sgn_id,
       sdv.dvs_id,
       sdv.name,
       vsn.vsn_id,
       NVL(vsn.valchar, vsn.valnum) varch,
       sdv.ord,
       obj.prj_id       
from xcls c, ocl, obj, sdv, oclp, vso, vds, vsn, nmpp
where ocl.mlt_id = c.mlt_id
  and ocl.clf_id = c.clf_id
  and ocl.cls_id = c.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and sdv.mlt_id = c.mlt_id
  and sdv.clf_id = c.clf_id
  and sdv.cls_id = c.cls_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and vds.mlt_id = vso.mlt_id
  and vds.clf_id = vso.clf_id
  and vds.cls_id = vso.cls_id
  and vds.sgn_id = vso.sgn_id
  and vds.dvs_id = vso.dvs_id
  and vds.vsn_id = vso.vsn_id
  and vds.mlt_id = vsn.mlt_id
  and vds.sgn_id = vsn.sgn_id
  and vds.vsn_id = vsn.vsn_id
  and sdv.mlt_id = nmpp.mlt_id
  and sdv.clf_id = nmpp.clf_id
  and sdv.cls_id = nmpp.cls_id
  and sdv.mlt_id = vds.mlt_id
  and sdv.clf_id = vds.clf_id
  and sdv.cls_id = vds.cls_id
  and sdv.sgn_id = vds.sgn_id
  and sdv.dvs_id = vds.dvs_id
  and REGEXP_LIKE (nmpp.fname, '\[&?' || sdv.dvs_id || '\]')
  and ocl.mlt_id = :mlt_id
  and sdv.cfv_id = :cfv_id
  and ocl.clf_id = :inclf_id
  and obj.prj_id = :prj_id
  and exists (select 1 from vobj 
              where obj.mlt_id = vobj.mlt_id
                and obj.obj_id = vobj.obj_id
                and vobj.aobj_id = :aobj_id)                              
UNION
select c.mlt_id,
       c.clf_id, 
       c.cls_id,
       c.code,
       c.name name_cls,
       obj.obj_id,
       oclp.sname,
       oclp.fname,
       sdv.sgn_id,
       sdv.dvs_id,
       sdv.name,
       vsn.vsn_id,
       NVL(vsn.valchar, vsn.valnum) varch,
       sdv.ord,
       obj.prj_id    
from xcls c, ocl, obj, sdv, oclp, vso, vds, vsn, nmpp
where ocl.mlt_id = c.mlt_id
  and ocl.clf_id = c.clf_id
  and ocl.cls_id = c.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and sdv.mlt_id = c.mlt_id
  and sdv.clf_id = c.clf_id
  and sdv.cls_id = c.cls_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and vds.mlt_id = vso.mlt_id
  and vds.clf_id = vso.clf_id
  and vds.cls_id = vso.cls_id
  and vds.sgn_id = vso.sgn_id
  and vds.dvs_id = vso.dvs_id
  and vds.vsn_id = vso.vsn_id
  and vds.mlt_id = vsn.mlt_id
  and vds.sgn_id = vsn.sgn_id
  and vds.vsn_id = vsn.vsn_id
  and sdv.mlt_id = nmpp.mlt_id
  and sdv.clf_id = nmpp.clf_id
  and sdv.cls_id = nmpp.cls_id
  and sdv.mlt_id = vds.mlt_id
  and sdv.clf_id = vds.clf_id
  and sdv.cls_id = vds.cls_id
  and sdv.sgn_id = vds.sgn_id
  and sdv.dvs_id = vds.dvs_id
  and REGEXP_LIKE (nmpp.fname, '\[&?' || sdv.dvs_id || '\]')
  and ocl.mlt_id = :mlt_id
  and sdv.cfv_id = :cfv_id
  and obj.prj_id = :prj_id
  and ocl.clf_id = 6
  and not exists (select 1 
                    from ocl q
                    where ocl.mlt_id = q.mlt_id
                      and ocl.obj_id = q.obj_id
                      and q.clf_id = :inclf_id)
  and exists (select 1 from vobj 
              where obj.mlt_id = vobj.mlt_id
                and obj.obj_id = vobj.obj_id
                and vobj.aobj_id = :aobj_id)), 
zdvs AS (select xcls.clf_id_pp,
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
                         and regexp_like(nmpp.sname,'{([^[{]*)\[&?'||dvs.dvs_id||'\]'))),
zdvs1 AS (select xcls.clf_id_pp,
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
                         and regexp_like(nmpp.fname,'{([^[{]*)\[&?'||dvs.dvs_id||'\]'))),
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
          and zdvs.clf_id = 6
          and not exists (select 1 
                          from ocl 
                          where vso.mlt_id = ocl.mlt_id
                            and ocl.clf_id = 3530
                            and vso.obj_id = ocl.obj_id)
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)),
zvsn1 as (select distinct zdvs1.mlt_id,
                         zdvs1.clf_id_pp,
                         zdvs1.cls_id_pp,
                         zdvs1.code,
                         zdvs1.name, 
                         zdvs1.clf_id,
                         zdvs1.cls_id,
                         zdvs1.dvs_id,
                         zdvs1.sgn_id,
                         vso.vsn_id,
                         :prj_id prj_id
        from zdvs1, vds, vso
        where zdvs1.mlt_id = vds.mlt_id
          and zdvs1.clf_id = vds.clf_id
          and zdvs1.cls_id = vds.cls_id
          and zdvs1.sgn_id = vds.sgn_id
          and zdvs1.dvs_id = vds.dvs_id
          and vds.mlt_id = vso.mlt_id
          and vds.clf_id = vso.clf_id
          and vds.cls_id = vso.cls_id
          and vds.sgn_id = vso.sgn_id
          and vds.dvs_id = vso.dvs_id
          and vds.vsn_id = vso.vsn_id
          and zdvs1.clf_id = :inclf_id
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)
       UNION ALL 
       select distinct zdvs1.mlt_id,
                         zdvs1.clf_id_pp,
                         zdvs1.cls_id_pp,
                         zdvs1.code,
                         zdvs1.name, 
                         zdvs1.clf_id,
                         zdvs1.cls_id,
                         zdvs1.dvs_id,
                         zdvs1.sgn_id,
                         vso.vsn_id,
                         :prj_id prj_id
        from zdvs1, vds, vso
        where zdvs1.mlt_id = vds.mlt_id
          and zdvs1.clf_id = vds.clf_id
          and zdvs1.cls_id = vds.cls_id
          and zdvs1.sgn_id = vds.sgn_id
          and zdvs1.dvs_id = vds.dvs_id
          and vds.mlt_id = vso.mlt_id
          and vds.clf_id = vso.clf_id
          and vds.cls_id = vso.cls_id
          and vds.sgn_id = vso.sgn_id
          and vds.dvs_id = vso.dvs_id
          and vds.vsn_id = vso.vsn_id
          and zdvs1.clf_id = 6
          and not exists (select 1 
                          from ocl 
                          where vso.mlt_id = ocl.mlt_id
                            and ocl.clf_id = 3530
                            and vso.obj_id = ocl.obj_id)
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)),
endval as
(select zdvs1.mlt_id,
       zdvs1.clf_id_pp,
       zdvs1.cls_id_pp,
       zdvs1.code,
       zdvs1.name, 
       zdvs1.clf_id,
       zdvs1.cls_id,
       zdvs1.dvs_id,
       zdvs1.sgn_id,
       zdvs1.vsn_id,
       zdvs1.prj_id,
       SP_ACCEPTOR.return_values(zdvs1.mlt_id, zdvs1.clf_id, zdvs1.cls_id, zdvs1.prj_id, zdvs1.dvs_id, zdvs1.sgn_id, zdvs1.vsn_id,0) sval,
       SP_ACCEPTOR.return_values(zdvs.mlt_id, zdvs.clf_id, zdvs.cls_id, zdvs.prj_id, zdvs.dvs_id, zdvs.sgn_id, zdvs.vsn_id,0) val
from  zvsn zdvs, zvsn1 zdvs1
where zdvs.mlt_id (+) = zdvs1.mlt_id
  and zdvs.clf_id (+) = zdvs1.clf_id
  and zdvs.cls_id (+) = zdvs1.cls_id
  and zdvs.dvs_id (+) = zdvs1.dvs_id
  and zdvs.sgn_id (+) = zdvs1.sgn_id
  and zdvs.vsn_id (+) = zdvs1.vsn_id)
select a.mlt_id,
       a.clf_id, 
       a.cls_id,
       a.code,
       a.name_cls,
       a.obj_id,
       a.sname,
       a.fname,
       a.sgn_id,
       a.dvs_id,
       a.name||up_pulatov.ink_get_define_mnd(  :cfv_id,
                                               a.mlt_id,
                                               a.clf_id,
                                               a.cls_id,
                                               a.sgn_id,
                                               a.dvs_id) name,
       a.vsn_id,
       a.varch,
       a.ord, 
       (case when (a.sgn_id = 886711 and a.varch = 'бетонное') then a.varch
            when (a.sgn_id = 886710 and a.varch = 'ППУ') then a.varch
            else REPLACE(REPLACE(c.val, '<Отсутствует>', '[Пусто]'), '<Не требуется>', '[Пусто]') end) val,  
       (case when (a.sgn_id = 886711 and a.varch = 'бетонное') then a.varch
            when (a.sgn_id = 886710 and a.varch = 'ППУ') then a.varch
            else REPLACE(REPLACE(c.sval, '<Отсутствует>', '[Пусто]'), '<Не требуется>', '[Пусто]') end) sval
from xobj a, endval c
where a.mlt_id = c.mlt_id
  and a.clf_id = c.clf_id
  and a.cls_id = c.cls_id
  and a.sgn_id = c.sgn_id
  and a.dvs_id = c.dvs_id
  and a.vsn_id = c.vsn_id           
order by 4, 14

