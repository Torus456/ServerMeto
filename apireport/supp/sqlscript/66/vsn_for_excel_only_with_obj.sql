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
       level top_level,
       clv.top_level clv_lev,
       connect_by_isleaf list
from clv, cfv, prj 
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and (clv.cls_id = :cls_id or (:cls_id = -1 AND clv.clv_clf_id is null))
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clv.clv_cls_id
union all 
select clv.mlt_id,
       clv.clf_id,
       clv.cls_id,
       clv.clv_clf_id,
       clv.clv_cls_id,
       clv.name,
       clv.code,
       clv.cfv_id,
       prj.prj_id,
       prj.name project_name,
       level top_level,
       clv.top_level clv_lev,
       0 list
from clv, cfv, prj 
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
  and clv.cls_id <> :cls_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clv_clf_id = clv.clf_id
  and prior clv.clv_cls_id = clv.cls_id),
zvds as
(select distinct 
       bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.prj_id,
       dvs.mnd,
       dvs.sgn_id,
       dvs.dvs_id,
       sdv.code sdvname,
       sdv.name sdvcode,
       sgn.valtype,
       vds.vsn_id,
       vsn.valchar,
       vsn.symsgn,
       vsn.valnum,
       regexp_instr(nmpp.fname, '\[&?'||dvs.dvs_id||'\]') ord,
       regexp_count(nmpp.sname||nmpp.fname, '\[&'||dvs.dvs_id||'\]') cnt,
       regexp_count(nmpp.sname||nmpp.fname, '\[&?'||dvs.dvs_id||'\]\[#') cnt2,
       case when sgn.sgn_id = 8222 then 'vsna'
            when regexp_count(nmpp.sname||nmpp.fname, '\[&?'||dvs.dvs_id||'\]\[#') >= 2 then 'vsna'
            when regexp_count(nmpp.sname||nmpp.fname, '\[&'||dvs.dvs_id||'\]') >= 2 then 'symsgn'
            else 'valchar'
       end val_opt,
       case when regexp_count(nmpp.sname||nmpp.fname, '\[&?'||dvs.dvs_id||'\]\[#') >= 1 then 'vsna'
            when regexp_count(nmpp.sname||nmpp.fname, '\[&'||dvs.dvs_id||'\]') >= 1 then 'symsgn'
            else 'valchar'
       end val_opt2,
       case when regexp_count(nmpp.name, '\[&?'||dvs.dvs_id||'\]\[#') >= 1 then 'vsna'
            when regexp_count(nmpp.name, '\[&'||dvs.dvs_id||'\]') >= 1 then 'symsgn'
            else 'valchar'
       end val_mdn,
       REGEXP_SUBSTR(REGEXP_SUBSTR(nmpp.sname||nmpp.fname||nmpp.name, '(\['||dvs.dvs_id||'\])(\[#\d+\])', 1, 1, 'i', 2),'\d+') sgna_id
from bcls, nmpp, dvs, sdv, vds, sgn, vsn    
where bcls.mlt_id = nmpp.mlt_id
  and bcls.clf_id = nmpp.clf_id
  and bcls.cls_id = nmpp.cls_id
  and bcls.prj_id = nmpp.prj_id
  and nmpp.mlt_id = dvs.mlt_id
  and nmpp.clf_id = dvs.clf_id
  and nmpp.cls_id = dvs.cls_id
  and nmpp.prj_id = :prj_id
  and regexp_like(nmpp.fname||nmpp.name,'{([^[{]*)\[&?'||dvs.dvs_id||'\]')
  and dvs.mlt_id = vds.mlt_id
  and dvs.clf_id = vds.clf_id
  and dvs.cls_id = vds.cls_id
  and dvs.sgn_id = vds.sgn_id
  and dvs.dvs_id = vds.dvs_id
  and dvs.mlt_id = sgn.mlt_id
  and dvs.sgn_id = sgn.sgn_id
  and dvs.mlt_id = sdv.mlt_id
  and dvs.clf_id = sdv.clf_id
  and dvs.cls_id = sdv.cls_id
  and dvs.sgn_id = sdv.sgn_id
  and dvs.dvs_id = sdv.dvs_id
  and sdv.cfv_id = :cfv_id
  and vds.mlt_id = vsn.mlt_id
  and vds.sgn_id = vsn.sgn_id
  and vds.vsn_id = vsn.vsn_id
  and exists (select 1 
              from vso
              where vds.mlt_id = vso.mlt_id
                and vds.clf_id = vso.clf_id
                and vds.cls_id = vso.cls_id
                and vds.sgn_id = vso.sgn_id
                and vds.dvs_id = vso.dvs_id
                and vds.vsn_id = vso.vsn_id
                and vso.mlt_id = 1
                and vso.clf_id = :clf_id)),
zvsn as 
(select distinct
        zvds.mlt_id,
        zvds.clf_id,
        zvds.cls_id,
        zvds.sgn_id,
        zvds.dvs_id,
        zvds.vsn_id,
        zvds.sdvname,
        zvds.mnd,
        zvds.ord,
        case when zvds.vsn_id = 0 then 'Не требуется'
             when zvds.sgna_id = 511 then up_pulatov.return_values_ns(zvds.mlt_id, zvds.clf_id, zvds.cls_id, zvds.sgn_id, zvds.dvs_id, zvds.vsn_id, zvds.prj_id, zvds.sgna_id)
             when zvds.mnd = 0 and zvds.val_mdn = 'vsna' then up_pulatov.return_values_ns(zvds.mlt_id, zvds.clf_id, zvds.cls_id, zvds.sgn_id, zvds.dvs_id, zvds.vsn_id, zvds.prj_id, zvds.sgna_id)
             when zvds.mnd = 0 and zvds.val_mdn = 'symsgn' then zvds.symsgn
             when zvds.valtype = 0 and val_opt = 'valchar' then zvds.valchar
             else replace(regexp_replace(replace(to_char(zvds.valnum), ',', '.'), '^\.', '0.'), ',', '.') 
        end value,
        case when zvds.valtype = 1 then ''
             when zvds.sgna_id = 511 then ''
             when zvds.valtype = 0 and val_opt2 = 'vsna' then up_pulatov.return_values_ns(zvds.mlt_id, zvds.clf_id, zvds.cls_id, zvds.sgn_id, zvds.dvs_id, zvds.vsn_id, zvds.prj_id, zvds.sgna_id)
             when zvds.valtype = 0 and val_opt2 = 'symsgn' then zvds.symsgn
             else to_char(sp_acceptor.return_values (zvds.mlt_id, zvds.clf_id, zvds.cls_id, zvds.prj_id, zvds.dvs_id, zvds.sgn_id, zvds.vsn_id, 1, 1)) 
             end symsgn,
        zvds.cnt,     
        valchar,
        val_opt,
        sgna_id
from zvds),
xobj as
(select mlt_id,
       clf_id,
       cls_id,
       code,
       name,
       obj_name,
       sname,
       fname,
       obj_id
from             
(select mlt_id,
       clf_id,
       cls_id,
       code,
       name,
       obj_name,
       sname,
       fname,
       obj_id,
       row_number() over (partition by fname order by obj_id) rn
from 
(select distinct xcls.mlt_id, 
       xcls.clf_id, 
       xcls.cls_id,
       xcls.code,
       xcls.name,
       oclp.sname,
       oclp.fname,
       obj.obj_id,
       obj.name obj_name
from bcls xcls, ocl, obj, oclp, oum, ums
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
  and oclp.fname not like '%?%'
  and oclp.prj_id = xcls.prj_id
  and obj.mlt_id = oum.mlt_id (+)
  and obj.obj_id = oum.obj_id (+)
  and obj.prj_id = oum.prj_id (+)
  and oum.cst_id (+) = :cst_id
  and oum.ums_id = ums.ums_id (+)
  and not exists (select 1 
                  from vobj 
                  where vobj.mlt_id = obj.mlt_id
                    and vobj.obj_id = obj.obj_id
                    and vobj.aobj_id = 9291)
  and exists (select 1 from vobj 
              where obj.mlt_id = vobj.mlt_id
                and obj.obj_id = vobj.obj_id
                and vobj.aobj_id = :aobj_id)))
),
unq as
(select  xobj.mlt_id,
        xobj.clf_id,
        xobj.cls_id,
        xobj.code, 
        xobj.name,
        xobj.obj_name,
        xobj.sname,
        xobj.fname,
        xobj.obj_id,
        zvsn.dvs_id,
        zvsn.sdvname,
        case when (zvsn.value = '<Отсутствует>' or zvsn.value is null) then zvsn.valchar else zvsn.value end value,
        zvsn.ord 
from xobj, ocl, vso, zvsn 
where xobj.mlt_id = ocl.mlt_id
  and xobj.clf_id = ocl.clf_id
  and xobj.cls_id = ocl.cls_id
  and xobj.obj_id = ocl.obj_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and vso.mlt_id = zvsn.mlt_id
  and vso.clf_id = zvsn.clf_id
  and vso.cls_id = zvsn.cls_id
  and vso.dvs_id = zvsn.dvs_id
  and vso.sgn_id = zvsn.sgn_id
  and vso.vsn_id = zvsn.vsn_id
  and zvsn.mnd = 1)
select distinct *
from (select distinct fname "Наименование товара", sname "Краткое наименование", name "Тип продукта", obj_id, sdvname, value from unq)
pivot ( max(value)
for (sdvname) in (:DVSFIELDS:)
)
order by 1