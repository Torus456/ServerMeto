from django.contrib import admin
from django.contrib.auth.admin import UserAdmin


MDG_USER_FIELDS = (
    ('Вход в систему', {
        'fields': ('username', 'password', 'last_login', 'is_staff', 'is_superuser')
    }),
    ('Контактная информация', {
        'fields': ('first_name', 'last_name', 'email', 'phone', 'timezone',)
    }),
    ('Роль в MDM процессе', {
        'fields': ('role',)
    })
)


class CUserAdmin(UserAdmin):
    '''
    Класс модели пользователя MDM
    '''
    # Поля и фильтры таблицы
    list_display = ('username', 'role', 'first_name', 'last_name', 'email', 'phone',)
    list_filter = ('role', 'is_active',)

    # Поля подробной информации
    fieldsets = MDG_USER_FIELDS

# Register your models here.
