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
zcls
        AS (SELECT a.mlt_id,
                   a.clf_id,
                   a.cls_id,
                   a.code,
                   a.name,
                   a.root_cls cls_id_pp,
                   a.root_clf clf_id_pp,
                   REGEXP_REPLACE (gen_shbl_cls_pp_ink (:cfv_id,
                              a.mlt_id,
                   			  a.root_clf,
                   			  a.root_cls,
                              nmpp.sname,
                              1), '&|#', '') spattern,
                   REGEXP_REPLACE (gen_shbl_cls_pp_ink (:cfv_id,
                              a.mlt_id,
                   			  a.root_clf,
                   			  a.root_cls,
                              nmpp.fname,
                              1), '&|#', '') fpattern
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
                                AND PRIOR cls_id = cls_cls_id) a, nmpp
                WHERE a.mlt_id = nmpp.mlt_id 
                  and a.root_clf = nmpp.clf_id
                  and a.root_cls = nmpp.cls_id
                  and nmpp.prj_id = :prj_id
                  and gen_shbl_dvs_sgn(a.mlt_id,a.clf_id,a.cls_id,:prj_id,1) = gen_shbl_dvs_sgn(a.mlt_id,a.root_clf,a.root_cls,:prj_id,1)),
zdvs AS (
         select zcls.clf_id_pp,
                zcls.cls_id_pp,
                bcls.code cls_code,
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
                ums494.code ei_norm,
                zcls.spattern,
                zcls.fpattern,
                :prj_id prj_id,
                :cfv_id cfv_id,
                :inclf_id inclf_id,
                :cst_id cst_id,
                :aobj_id aobj_id  
         from bcls, zcls, dvs, cum, ums, cum cum494, ums ums494
         where dvs.mlt_id = 1
           and dvs.mlt_id = zcls.mlt_id
           and dvs.clf_id = zcls.clf_id
           and dvs.cls_id = zcls.cls_id
           and zcls.mlt_id = bcls.mlt_id
           and zcls.clf_id_pp = bcls.clf_id
           and zcls.cls_id_pp = bcls.cls_id
           and zcls.mlt_id = cum.mlt_id (+)
           and zcls.clf_id_pp = cum.clf_id (+)
           and zcls.cls_id_pp = cum.cls_id (+)
           and cum.prj_id (+) = :prj_id
           and cum.cst_id (+) = :cst_id
           and cum.ums_id = ums.ums_id (+)
           and zcls.mlt_id = cum494.mlt_id (+)
           and zcls.clf_id_pp = cum494.clf_id (+)
           and zcls.cls_id_pp = cum494.cls_id (+)
           and cum494.prj_id (+) = :prj_id
           and cum494.cst_id (+) = 494
           and cum494.ums_id = ums494.ums_id (+)          
           and exists (select 1 
                       from nmpp
                       where dvs.mlt_id = nmpp.mlt_id
                         and dvs.clf_id = nmpp.clf_id
                         and dvs.cls_id = nmpp.cls_id
                         and nmpp.prj_id = :prj_id
                         and regexp_like(nmpp.sname||nmpp.fname,'{([^[{]*)\[&?'||dvs.dvs_id||'\]'))),
/* выбираем значения по ОД */
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
                         67 prj_id,
                         vsn.valchar,
                         vsn.valnum,
                         sgn.valtype
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
                         67 prj_id,
                         vsn.valchar,
                         vsn.valnum,
                         sgn.valtype
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
          and zdvs.clf_id = 6
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
       case when zdvs.valtype = 1 and to_char(zdvs.vsn_id) = '0'
            then '<Не требуется>'
            when zdvs.valtype = 1
            then replace(regexp_replace(replace(to_char(zdvs.valnum), ',', '.'), '^\.', '0.'), '.', ',') 
            else regexp_replace(SP_ACCEPTOR.return_values(zdvs.mlt_id, zdvs.clf_id, zdvs.cls_id, zdvs.prj_id, zdvs.dvs_id, zdvs.sgn_id, zdvs.vsn_id,0), '^=', '''=') 
       end val
from  zvsn zdvs),
unq as
(select distinct zdvs.mlt_id, 
				 zdvs.clf_id, 
				 zdvs.cls_id, 
				 zdvs.cls_code, 
				 zdvs.cls_name,
                 zdvs.spattern,
                 zdvs.fpattern,
				 oclp.obj_id, 
				 obj.name obj_name,
				 obj.code code_nsi, 
				 nvl(ums.code, zdvs.ei)  ei, 
				 nvl(ums494.code, zdvs.ei_norm)  ei_norm,
				 cls.name grp,
				 nvl(art.artikul, '-') artikul,
				 obj.sname descr,
				 (select clv.name 
				 from clv
				 where clv.mlt_id = bcls.mlt_id
				   and clv.clf_id = bcls.clv_clf_id
				   and clv.cls_id = bcls.clv_cls_id
				   and clv.cfv_id = bcls.cfv_id) root,
				 bcls.descr standard,
				 vcomm.valchar comm,
				 replace_code_name(oclp.mlt_id, oclp.clf_id, oclp.cls_id, zdvs.cfv_id, oclp.fname, 1) as fname,
				 replace_code_name(oclp.mlt_id, oclp.clf_id, oclp.cls_id, zdvs.cfv_id, oclp.sname, 1) as sname, 
				 case when oclp.sname||oclp.fname like '%?%' then 'Ненормализовано' else 'Нормализовано' end normal,
                 case when count( distinct obj.obj_id) over (PARTITION BY oclp.sname) > 1 and oclp.sname||oclp.fname not like '%?%' then 'Дубль' else null end  duble,                 
				 sdv.code, 
				 sdv.name, 
				 e.val 
from zdvs, dvs, sdv, 
     vds, vso, obj, 
     endval e, oclp, 
     oum, ums, 
     oum oum494, ums ums494,  
     ocl, cls, 
     cs_art_load.ink_artikul art, 
     clv bcls,
     vso comm,
     vsn vcomm
where zdvs.mlt_id = dvs.mlt_id
  and zdvs.clf_id_pp = dvs.clf_id
  and zdvs.cls_id_pp = dvs.cls_id
  and zdvs.sgn_id = dvs.sgn_id
  and zdvs.name = dvs.name 
  and zdvs.cfv_id = sdv.cfv_id
  and dvs.mlt_id = sdv.mlt_id
  and dvs.clf_id = sdv.clf_id
  and dvs.cls_id = sdv.cls_id
  and dvs.sgn_id = sdv.sgn_id
  and dvs.dvs_id = sdv.dvs_id
  and sdv.mlt_id = bcls.mlt_id
  and sdv.clf_id = bcls.clf_id
  and sdv.cls_id = bcls.cls_id
  and sdv.cfv_id = bcls.cfv_id
  and zdvs.mlt_id = vds.mlt_id
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
  and vso.mlt_id = oclp.mlt_id
  and vso.clf_id = oclp.clf_id
  and vso.cls_id = oclp.cls_id
  and vso.obj_id = oclp.obj_id
  and oclp.prj_id = :prj_id
  and obj.mlt_id = oclp.mlt_id
  and obj.obj_id = oclp.obj_id
  and obj.prj_id = oclp.prj_id
  and obj.status = 1
  and (oclp.clf_id = :inclf_id or (oclp.clf_id = 6 and not exists (select 1 
                          from ocl 
                          where vso.mlt_id = ocl.mlt_id
                            and ocl.clf_id = :inclf_id
                            and vso.obj_id = ocl.obj_id)))   
  and obj.mlt_id = oum.mlt_id (+)
  and obj.obj_id = oum.obj_id (+)
  and obj.prj_id = oum.prj_id (+)
  and oum.ums_id = ums.ums_id (+)
  and oum.cst_id (+) = 487
  and obj.mlt_id = oum494.mlt_id (+)
  and obj.obj_id = oum494.obj_id (+)
  and obj.prj_id = oum494.prj_id (+)
  and oum494.cst_id (+) = 494
  and oum494.ums_id = ums494.ums_id (+)
  and obj.mlt_id = ocl.mlt_id (+)
  and obj.obj_id = ocl.obj_id (+)
  and ocl.clf_id (+) = 3510
  and ocl.mlt_id = cls.mlt_id
  and ocl.clf_id = cls.clf_id
  and ocl.cls_id = cls.cls_id
  and obj.obj_id = art.obj_id (+)
  and obj.mlt_id = comm.mlt_id (+)
  and obj.obj_id = comm.obj_id (+)
  and comm.mlt_id = vcomm.mlt_id (+)
  and comm.clf_id (+) = :clf_id
  and comm.sgn_id = vcomm.sgn_id (+)
  and comm.vsn_id = vcomm.vsn_id (+)
  and comm.sgn_id (+) = 886147
  and vso.mlt_id = e.mlt_id
  and vso.clf_id = e.clf_id
  and vso.cls_id = e.cls_id
  and vso.sgn_id = e.sgn_id
  and vso.dvs_id = e.dvs_id
  and vso.vsn_id = e.vsn_id)
select distinct *
from (select distinct mlt_id, 
					  clf_id, 
					  cls_id, 
					  obj_id, 
					  obj_name  as "Наименование", 
					  code_nsi  as "Код НСИ", 
					  ei 	    as "ЕИ",
					  grp       as "Группа", 
					  artikul   as "Артикул", 
					  descr     as "Описание",
					  root      as "Класс 1 уровня",
					  cls_name  as "Класс 2 уровня", 
					  standard  as "Стандарт",
					  spattern  as "Шаблон краткого наименования",
					  fpattern  as "Шаблон полного наименования",
					  ei_norm   as "ЕИ нормализованная",
					  sname     as "Наименования краткое",
					  fname     as "Наименования полное",
                      code name, 
					  val ,
					  normal    as "Итог нормализации",
					  listagg(comm, ';') within group (order by comm)     as "Комментарий ИНКОН",
					  null      as "Комментарий заказчика",
					  duble		  as "Дубль"
					  
		from unq
        GROUP BY      mlt_id, 
                      clf_id,
                      cls_id, 
                      obj_id, 
                      obj_name, 
                      code_nsi, 
                      ei, 
                      grp, 
                      artikul, 
                      descr, 
                      root,
					  cls_name, 
					  standard,
					  spattern,
					  fpattern,
					  ei_norm,
					  sname,
					  fname,
            code, 
					  val,
					  normal,					  
					  duble	)
pivot ( max(val)
for (name) in (:DVSFIELDS:)
)
order by "Наименования краткое"