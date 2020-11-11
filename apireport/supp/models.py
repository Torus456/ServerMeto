from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    '''Наследуем пользователя от джанговского'''

    phone = models.CharField(
        max_length=40, null=True, blank=True, verbose_name='Номер телефона'
    )
    timezone = models.CharField(
        max_length=40, null=True, blank=True, verbose_name='Часовой пояс'
    )

    role = models.ForeignKey(
        'Role',
        db_index=True,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        verbose_name='Роль'
    )

    def __str__(self):
        return '{0}: {1} - {2} {3}'.format(
            self.id, self.username, self.first_name, self.last_name
        )

    class Meta:
        verbose_name = 'Пользователь'
        verbose_name_plural = 'Пользователи'


class Role(models.Model):
    '''Справочник ролей MDG-процесса'''

    code = models.CharField(db_index=True, max_length=40, null=False)
    name = models.CharField(db_index=True, max_length=40, null=False)
    fieldname = models.CharField(
        db_index=True,
        max_length=40,
        null=False,
        default='created_by_id'
    )

    def __str__(self):
        return '{0}: {1}'.format(self.code, self.name)

    class Meta:
        verbose_name = 'Роль'
        verbose_name_plural = 'Роли'
