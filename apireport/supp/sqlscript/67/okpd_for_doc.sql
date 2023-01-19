WITH bcls
        AS (    SELECT   a.cfv_id,a.mlt_id,
                         a.clf_id,
                         a.cls_id,
                         a.parent,
                         a.status,
                         a.name,
                         a.code,
                         a.code_key,
                         a.clv_clf_id,
                         a.clv_cls_id,
                         CONNECT_BY_ISLEAF list,
                         LEVEL top_level
                  FROM   (select * from clv where clv.cfv_id = :cfv_id and clv.mlt_id = :mlt_id and status <> 2) a
            START WITH       cfv_id = :cfv_id
                         AND mlt_id = :mlt_id
                         AND clf_id = :clf_id
                         AND (cls_id = :cls_id OR (:cls_id = -1 AND clv_cls_id IS NULL))
            CONNECT BY      PRIOR cfv_id = cfv_id
                         AND PRIOR mlt_id = mlt_id
                         AND PRIOR clf_id = clv_clf_id
                         AND PRIOR cls_id = clv_cls_id),
    zcls
        AS (SELECT   *
              FROM   (    SELECT   DISTINCT
                                   cls.mlt_id,
                                   cls.clf_id,
                                   cls.cls_id,
                                   cls.code,
                                   cls.name,
                                   CONNECT_BY_ROOT (cls.cls_id) root_cls,
                                   CONNECT_BY_ROOT (cls.clf_id) root_clf,
                                   LEVEL lev,
                                   :prj_id prj_id,
                                   :cst_id cst_id,
                                   :inclf_id inclf_id,
                                   :aobj_id aobj_id
                            FROM   cls
                           WHERE   cls.mlt_id = 1
                      START WITH   cls.mlt_id = 1 AND cls.clf_id IN (6, 3530)
                                   AND EXISTS
                                          (SELECT   1
                                             FROM   bcls
                                            WHERE   bcls.list = 1
                                                    AND bcls.mlt_id =
                                                           cls.mlt_id
                                                    AND bcls.clf_id =
                                                           cls.clf_id
                                                    AND bcls.cls_id =
                                                           cls.cls_id)
                      CONNECT BY       PRIOR mlt_id = mlt_id
                                   AND PRIOR clf_id = clf_id
                                   AND PRIOR cls_id = cls_cls_id) a
             WHERE   gen_shbl_dvs_sgn (a.mlt_id,
                                       a.clf_id,
                                       a.cls_id,
                                       :prj_id,
                                       1) = gen_shbl_dvs_sgn (a.mlt_id,
                                                              a.root_clf,
                                                              a.root_cls,
                                                              :prj_id,
                                                              1)),                                                        
    xcls
        AS (SELECT   b.mlt_id,
                     NVL (z.clf_id, b.clf_id) AS clf_id,
                     NVL (z.cls_id, b.cls_id) AS cls_id,
                     b.clf_id AS clf_id_pp,
                     b.cls_id AS cls_id_pp,
                     b.code,
                     b.name,
                     b.parent
              FROM   bcls b, zcls z
             WHERE       b.mlt_id = z.mlt_id(+)
                     AND b.clf_id = z.root_clf(+)
                     AND b.cls_id = z.root_cls(+))

SELECT xcls.mlt_id
, xcls.clf_id
, xcls.cls_id
, xcls.code
, xcls.name
, clsb.code cod_okved
, clsb.name name_okved
, clst.code cod_okpd
, clst.name name_okpd
FROM xcls, car carb,cls clsb, car cart, cls clst
WHERE carb.cas_id = 319
AND xcls.mlt_id = carb.mlt_id
AND xcls.clf_id = carb.clf_id
AND xcls.cls_id = carb.cls_id 
AND carb.ass_mlt_id = clsb.mlt_id 
AND carb.ass_clf_id = clsb.clf_id 
AND carb.ass_cls_id = clsb.cls_id 
AND cart.cas_id = 318
AND xcls.mlt_id = cart.mlt_id 
AND xcls.clf_id = cart.clf_id 
AND xcls.cls_id = cart.cls_id
AND cart.ass_mlt_id = clst.mlt_id
AND cart.ass_clf_id = clst.clf_id 
AND cart.ass_cls_id = clst.cls_id
order by 4