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
       level clv_lev
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
nclv as
(select bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.clv_clf_id,
       bcls.clv_cls_id,
       bcls.name,
       bcls.code,
       bcls.cfv_id,
       bcls.prj_id,
       bcls.project_name,
       bcls.clv_lev,
       gen_shbl_cls_pp2(  bcls.cfv_id,
                          bcls.mlt_id,
                          bcls.clf_id,
                          bcls.cls_id,
                          nmpp.sname,
                          1) sname,
       gen_shbl_cls_pp2(  bcls.cfv_id,
                          bcls.mlt_id,
                          bcls.clf_id,
                          bcls.cls_id,
                          nmpp.fname,
                          1) fname,
                          nmpp.fname nfname
from bcls, nmpp
where bcls.mlt_id = nmpp.mlt_id 
  and bcls.clf_id = nmpp.clf_id
  and bcls.cls_id = nmpp.cls_id
  and bcls.prj_id = nmpp.prj_id)
select b.mlt_id,
       b.clf_id,
       b.cls_id,
       b.cfv_id,
       b.code cls_code,
       b.name cls_name,
       b.prj_id,
       b.project_name,
       sgn.sgn_id,
       sdv.dvs_id,
       sdv.code,
       sdv.name,
       sdv.ord,
       case when sgn.valtype = 0 then 'Текстовый' else 'Числовой' end valtype,
       case when vsn.vsn_id = 0 then vsn.symsgn
       		else case 
       		     when sgn.valtype = 0 
       		     then sp_acceptor.return_values (b.mlt_id,b.clf_id,b.cls_id,b.prj_id,sdv.dvs_id,sgn.sgn_id,vsn.vsn_id,0) 
       		     else regexp_replace(to_char(vsn.valnum), '^\.', '0.') 
       		 	 end 
       end value,
       sp_acceptor.return_values (b.mlt_id,b.clf_id,b.cls_id,b.prj_id,sdv.dvs_id,sgn.sgn_id,vsn.vsn_id,1) symsgn,
       :inclf_id incls_id
from nclv b, sdv, sgn, dvs, vds, vsn 
where b.mlt_id = sdv.mlt_id 
  and b.clf_id = sdv.clf_id 
  and b.cls_id = sdv.cls_id
  and b.cfv_id = sdv.cfv_id
  and sdv.mlt_id = sgn.mlt_id
  and sdv.sgn_id = sgn.sgn_id
  and sdv.mlt_id = dvs.mlt_id
  and sdv.clf_id = dvs.clf_id
  and sdv.cls_id = dvs.cls_id
  and sdv.sgn_id = dvs.sgn_id
  and sdv.dvs_id = dvs.dvs_id
  and dvs.mlt_id = vds.mlt_id 
  and dvs.clf_id = vds.clf_id
  and dvs.cls_id = vds.cls_id
  and dvs.sgn_id = vds.sgn_id
  and dvs.dvs_id = vds.dvs_id
  and vds.mlt_id = vsn.mlt_id
  and vds.sgn_id = vsn.sgn_id
  and vds.vsn_id = vsn.vsn_id
  and exists (select 1 
              from vso, obj 
              where vso.mlt_id = vds.mlt_id
                and vso.clf_id = vds.clf_id 
                and vso.cls_id = vds.cls_id
                and vso.sgn_id = vds.sgn_id
                and vso.dvs_id = vds.dvs_id
                and vso.vsn_id = vds.vsn_id
                and vso.mlt_id = obj.mlt_id
                and vso.obj_id = obj.obj_id
                and obj.prj_id = b.prj_id
                and exists (select 1
                			from vobj
                			where vobj.mlt_id = obj.mlt_id
                			  and vobj.obj_id = obj.obj_id
                			  and vobj.aobj_id = :aobj_id))
  and regexp_like(b.nfname,'{([^[{]*)\[&?'||sdv.dvs_id|| '\]')
order by b.code, sdv.ord