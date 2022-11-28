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
                            WHERE mlt_id = :mlt_id
                            START WITH mlt_id = :mlt_id 
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
          and zdvs.clf_id = 3530
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
from  zvsn zdvs)
select a.cfv_id,
       a.mlt_id,
       a.clf_id,
       a.cls_id,
       a.name_cls,  
       a.sgn_id,
       a.dvs_id,
       a.vsn_id,
       a.prj_id,
       a.code,
       a.name,
       a.Tip,
       a.ord,
       a.valchar,
       a.value,
       a.symsgn,
       a.rn,
       a.ord_val,
       :aobj_id,
       :inclf_id
from (select q.cfv_id,
       q.mlt_id,
       q.clf_id,
       q.cls_id,
       q.name_cl name_cls,  
       q.sgn_id,
       q.dvs_id,
       q.vsn_id,
       q.prj_id,
       q.code,
       q.name,
       sgn.valtype Tip,
       q.ord,
       NVL(vsn.valchar, vsn.valnum) valchar,
       (case when q.val = '<Не требуется>' then ''
             when q.val = '<Отсутствует>' then ''
             when (vsn.sgn_id = 886711 and vsn.valchar = 'бетонное') then vsn.valchar
             when (vsn.sgn_id = 886710 and vsn.valchar = 'ППУ') then vsn.valchar
             else q.val end) value,
       a.rasshifrovka_new as symsgn,
       dense_rank() over (partition by q.cfv_id, q.mlt_id, q.clf_id,q.cls_id ORDER BY q.ord) rn,
       case when sgn.valtype = 1 then to_char(vsn.valnum, '99999999999d9999') 
            when regexp_like(lower(q.name), 'дюйм|градус') and regexp_like(vsn.valchar, '[0-9]*[\.,]?*[0-9]') then up_pulatov.ink_to_number(vsn.valchar)
       else vsn.valchar 
       end ord_val
from (SELECT DISTINCT sdv.cfv_id,
                      sdv.mlt_id,
                      sdv.clf_id,
                      sdv.cls_id, 
                      sdv.sgn_id,
                      sdv.dvs_id,
                      a.vsn_id,
                      nmpp.prj_id,
                      sdv.code code_od,
                      sdv.name,
                      c.code code,
                      c.name name_cl,
                      a.val val,
                      a.sval sval,
                      sdv.ord ord
FROM bcls c, endval a, sdv, dvs, nmpp
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
  and REGEXP_LIKE (nmpp.sname || nmpp.fname, '\[&?' || sdv.dvs_id || '\]')) q, vsn, sgn, cs_art_load.ink_opisanie_zn a
where q.mlt_id = vsn.mlt_id
  and q.sgn_id = vsn.sgn_id
  and q.vsn_id = vsn.vsn_id
  and sgn.mlt_id = vsn.mlt_id
  and sgn.sgn_id = vsn.sgn_id
  and q.mlt_id = a.mlt_id (+)
  and q.cls_id = a.cls_id (+)
  and q.sgn_id = a.sgn_id (+)
  and q.dvs_id = a.dvs_id (+)
  and q.vsn_id = a.vsn_id (+)) a
where (a.value is not null or a.symsgn is not null)
ORDER BY 5, ord, ord_val, value

