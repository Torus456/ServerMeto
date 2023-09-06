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
         FROM (select * from clv where clv.mlt_id = :mlt_id and clv.cfv_id = :cfv_id and clv.status <> 2)
         WHERE status <> 2
         START WITH cfv_id = :cfv_id
             AND mlt_id = :mlt_id 
             AND clf_id = :clf_id
             AND cls_id = :cls_id
         CONNECT BY PRIOR cfv_id = cfv_id
             AND PRIOR mlt_id = mlt_id
             AND PRIOR clf_id = clv_clf_id
             AND PRIOR cls_id = clv_cls_id),
zdvs AS (
         select  bcls.code cls_code,
                bcls.name cls_name,
                dvs.mlt_id,
                dvs.clf_id,
                dvs.cls_id,
                dvs.sgn_id,
                dvs.dvs_id,
                dvs.code,
                dvs.name,
                dvs.status,
                ums.code ei,
                :prj_id prj_id,
                :cfv_id cfv_id,
                :inclf_id inclf_id,
                :cst_id cst_id,
                :aobj_id aobj_id  
         from bcls, sdv dvs, cum, ums
         where bcls.mlt_id = dvs.mlt_id
           and bcls.clf_id = dvs.clf_id
           and bcls.cls_id = dvs.cls_id
           and bcls.cfv_id = dvs.cfv_id
           and bcls.mlt_id = cum.mlt_id (+)
           and bcls.clf_id = cum.clf_id (+)
           and bcls.cls_id = cum.cls_id (+)
           and cum.cst_id (+) = :cst_id
           and cum.ums_id = ums.ums_id(+)        
           and exists (select 1 
                       from nmpp
                       where dvs.mlt_id = nmpp.mlt_id
                         and dvs.clf_id = nmpp.clf_id
                         and dvs.cls_id = nmpp.cls_id
                         and nmpp.prj_id = :prj_id
                         and regexp_like(nmpp.sname||nmpp.fname,'{([^[{]*)\[&?'||dvs.dvs_id||'\]'))),
/* выбираем значения по ОД */
zvsn as (select distinct zdvs.mlt_id,
                         zdvs.code,
                         zdvs.name, 
                         zdvs.clf_id,
                         zdvs.cls_id,
                         zdvs.dvs_id,
                         zdvs.sgn_id,
                         vso.vsn_id,
                         73 prj_id,
                         vsn.valchar,
                         vsn.valnum,
                         sgn.valtype,
                         vds.uion
        from zdvs, vds, vso, vsn, sgn 
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
          and vds.mlt_id = vsn.mlt_id
          and vds.sgn_id = vsn.sgn_id
          and vds.vsn_id = vsn.vsn_id
          and vds.mlt_id = sgn.mlt_id
          and vds.sgn_id = sgn.sgn_id
          and zdvs.clf_id = :clf_id
          and exists (select 1 
                      from obj
                      where obj.mlt_id = vso.mlt_id
                        and obj.obj_id = vso.obj_id
                        and obj.status = 1
                        and obj.prj_id = :prj_id)),
endval as
(select zdvs.mlt_id,
       zdvs.code,
       zdvs.name, 
       zdvs.clf_id,
       zdvs.cls_id,
       zdvs.dvs_id,
       zdvs.sgn_id,
       zdvs.vsn_id,
       prj_id,
       case when zdvs.valtype = 1 and to_char(zdvs.vsn_id) = '0'
            then ''
            when zdvs.valtype = 1
            then replace(regexp_replace(replace(to_char(zdvs.valnum), ',', '.'), '^\.', '0.'), ',', '.') 
            when zdvs.uion = 1 then zdvs.valchar
            else zdvs.valchar
       end val
from  zvsn zdvs),
unq as 
(SELECT  glava_artikul, 
        glava, 
        razdel_artikul, 
        razdel, 
        podrazdel_artikul, 
        podrazdel, 
        id, 
        kod, 
        nomenklatura, 
        baz_ei, 
        cls.code cls_code, 
        cls.name, 
        oclp.sname,
        case when oclp.sname not like '%?%' then '1' else '0' end status,
        nvl(ums.code, zdvs.ei) ums_code,
        zdvs.code dvs_code, 
        zdvs.name dvs_name, 
        e.val 
FROM obj, ocl, oclp,
     cls, bcls, zdvs,
     vso, endval e,
     oum, ums,
     cs_art_load.crost_obj a 
where obj.mlt_id = 1 
  and obj.prj_id = :prj_id
  and obj.obj_id = a.obj_id
  and obj.status = 1
  and obj.mlt_id = ocl.mlt_id
  and obj.obj_id = ocl.obj_id
  and ocl.mlt_id = cls.mlt_id
  and ocl.clf_id = cls.clf_id
  and ocl.cls_id = cls.cls_id
  and bcls.mlt_id = cls.mlt_id
  and bcls.clf_id = cls.clf_id
  and bcls.cls_id = cls.cls_id
  and cls.mlt_id = zdvs.mlt_id
  and cls.clf_id = zdvs.clf_id
  and cls.cls_id = zdvs.cls_id
  and obj.mlt_id = oclp.mlt_id
  and cls.clf_id = oclp.clf_id
  and cls.clf_id = oclp.clf_id
  and cls.cls_id = oclp.cls_id
  and obj.obj_id = oclp.obj_id
  and obj.prj_id = oclp.prj_id
  and oclp.prj_id = :prj_id
  and zdvs.mlt_id = vso.mlt_id
  and zdvs.clf_id = vso.clf_id
  and zdvs.cls_id = vso.cls_id
  and zdvs.dvs_id = vso.dvs_id
  and zdvs.sgn_id = vso.sgn_id
  and obj.mlt_id = vso.mlt_id
  and obj.obj_id = vso.obj_id 
  and vso.mlt_id = e.mlt_id
  and vso.clf_id = e.clf_id
  and vso.cls_id = e.cls_id
  and vso.sgn_id = e.sgn_id
  and vso.dvs_id = e.dvs_id
  and vso.vsn_id = e.vsn_id
  AND obj.mlt_id = oum.mlt_id (+)
  AND obj.obj_id = oum.obj_id (+)
  AND oum.cst_id (+) = :cst_id
  AND oum.ums_id = ums.ums_id (+))
select distinct *
from (select distinct glava_artikul         "Глава Артикул", 
        glava                               "Глава", 
        razdel_artikul                      "Раздел Артикул", 
        razdel                              "Раздел", 
        podrazdel_artikul                   "Подраздел Артикул", 
        podrazdel                           "Подраздел", 
        id                                  "ИД номенклатуры", 
        kod                                 "Код номенклатуры", 
        nomenklatura                        "Номенклатура", 
        baz_ei                              "ЕИ", 
        cls_code                            "Класс", 
        name                                "Наименование класса", 
        sname                               "Наименование материала", 
        ums_code                            "ЕИ Нормализованная",
        dvs_code                            name,
        val,
        status                              "Статус записи",
        null                                "Замечания" 
        from unq)
pivot (max(val)
for (name) in (:DVSFIELDS:)
)
order by 7