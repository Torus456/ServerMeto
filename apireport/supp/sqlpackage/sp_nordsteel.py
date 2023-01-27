

class SpNordSteel:

    # Класс для взаимодействия с процедурами для Северсталь. Металлопрокат

    def create_cls(self, cur, data):
        """
            Создаем пустой класс
        """
        val = (
            data["MLT_ID"],
            data["CLF_ID"],
            data["CLS_CLS_ID"],
            data["CLS_LEV"],
            data["NAME"],
            data["DESCR"],
            data["NMPP_SNAME"],
            data["NMPP_FNAME"]
        )
        result = cur.callfunc('sp_nordsteel_metal.create_cls', int, val)
        return result

    def find_and_copy_cls(self, cur, data):
        """
            Ищем класс по наименованию в существующей структуре классов ПП
            и копируем класс  в акртуальную структуру
        """
        val = (
            data["MLT_ID"],
            data["CLF_ID"],
            data["CLS_CLS_ID"],
            data["NAME"],
            data["NMPP_SNAME"],
            data["NMPP_FNAME"]
        )
        result = cur.callfunc('sp_nordsteel_metal.find_cls', int, val)
        return result

    def drop_cls(self, cur, data):
        """
            Очистка данных для загрузки актуальной версии
        """
        sql_insert = """
                        begin
                            sp_nordsteel_metal.clear_data(
                                :p_mlt_id,
                                :p_clf_id
                            );
                        end;
                    """
        val = (
            data["MLT_ID"],
            data["CLF_ID"]
        )
        cur.execute(sql_insert, val)

    def check_or_create_dvs(self, cur, data):
        """
            Проверяем наличие ОД в классе.
            При отсутвии подходящего добавляем нужный признак и ОД
        """
        sql_insert = """
                        begin
                            sp_nordsteel_metal.check_or_create_dvs(
                                :p_mlt_id,
                                :p_clf_id,
                                :p_cls_id,
                                :p_dvs_name,
                                :p_dvs_type,
                                :p_dvs_required,
                                :p_dvs_option
                            );
                        end;
                    """
        val = (
            data["MLT_ID"],
            data["CLF_ID"],
            data["CLS_ID"],
            data["DVS_NAME"],
            data["DVS_TYPE"],
            data["DVS_REQUIRED"],
            data["DVS_OPTION"]
        )
        cur.execute(sql_insert, val)

    def sinh_cls_names(cur):
        """
        Синхронизация наименований классов
        """
        sql_insert = """
                        begin
                            sp_nordsteel_metal.sinh_name;
                        end;
                    """
        cur.execute(sql_insert)

    def parse_json(self, cur, json):
        data = {
            "MLT_ID": 1,
            "CLF_ID": 3571,
            "CLS_CLS_ID": "",
            "CLS_LEV": 1,
            "NAME": "ПЕрвый класс",
            "DESCR": ""
        }
        self.drop_cls(cur, data)
        for frag in self.json_data["categories"]:
            data["NAME"] = frag["name"]
            data["CLS_CLS_ID"] = ""
            data["CLS_LEV"] = 1
            data["NMPP_SNAME"] = ""
            data["NMPP_FNAME"] = ""
            cls_cls_id = self.create_cls(cur, data)
            for cls2 in frag["children"]:
                data["NAME"] = cls2["name"]
                data["CLS_CLS_ID"] = cls_cls_id
                data["CLS_LEV"] = 2
                data["NMPP_SNAME"] = ""
                data["NMPP_FNAME"] = ""
                cls_cls_id2 = self.create_cls(cur, data)
                for cls3 in cls2["children"]:
                    data["NAME"] = cls3["name"]
                    data["CLS_CLS_ID"] = cls_cls_id2
                    data["CLS_LEV"] = 3
                    data["NMPP_SNAME"] = ""
                    data["NMPP_FNAME"] = ""
                    cls_cls_id3 = self.create_cls(cur, data)
                    for cls4 in cls3["children"]:
                        data["NAME"] = cls4["name"]
                        info_model = cls4["informationModel"]
                        data["CLS_CLS_ID"] = cls_cls_id3
                        data["CLS_LEV"] = 4
                        data["NMPP_SNAME"] = info_model["productName"]
                        data["NMPP_FNAME"] = info_model["productShortName"]
                        cls_id = self.find_and_copy_cls(cur, data)
                        if (cls_id is None or cls_id < 0):
                            cls_id = self.create_cls(cur, data)
                        data["CLS_ID"] = cls_id
        #               Грузим базовые атрибуты
                        if info_model["attributes"]:
                            for attrib in info_model["attributes"]:
                                data["DVS_NAME"] = attrib["name"]
                                data["DVS_TYPE"] = attrib["type"]
                                data["DVS_REQUIRED"] = attrib["required"]
                                if (attrib["isBasic"]):
                                    data["DVS_OPTION"] = "BASIC"
                                elif (attrib["isAuxiliary"]):
                                    data["DVS_OPTION"] = "AUXILIARY"
                                else:
                                    data["DVS_OPTION"] = "SUPPLIER"
                                self.check_or_create_dvs(cur, data)
        self.sinh_cls_names(cur)


nordsteel = SpNordSteel()
