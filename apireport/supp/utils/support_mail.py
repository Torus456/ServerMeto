import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.header import Header
from email import encoders
from email.mime.multipart import MIMEMultipart


def sendmail(address_mail, subject_mail, text_mail, file_attachment, name_attachment):
    """
    Отправить данные на почту:
    @address_mail - почта
    @subject_mail - тема письма
    @text_mail - текст письма
    @attachment - ссылка на файл
    """
    EMAIL_HOST = '192.168.54.11'
    EMAIL_PORT = 25
    EMAIL_HOST_USER = 'galka'
    EMAIL_HOST_PASSWORD = "Schpil59Do"
    # EMAIL_USE_TLS = True
    DEFAULT_FROM_EMAIL = 'support@incon.ru'
    # SUBJECT = "Согласование материалов"
    file_to_attach = file_attachment  # os.path.join(settings.BASE_DIR, "Instruction.docx")
    addresses = []
    addresses.append(address_mail)
    # Готовим сообщение
    msg = MIMEMultipart('alternative')
    # msg.attach(MIMEText(html, 'html', 'utf-8'))
    msg['Subject'] = Header(subject_mail, 'utf-8')
    msg['From'] = DEFAULT_FROM_EMAIL
    msg['To'] = ','.join(addresses)
    print(name_attachment)
    header = 'Content-Disposition', 'attachment; filename="%s"' % name_attachment #'Galka_Instruction.docx'
    attachment = MIMEBase('application', "octet-stream")
    try:
        with open(file_to_attach, "rb") as fh:
            data = fh.read()
        attachment.set_payload(data)
        encoders.encode_base64(attachment)
        attachment.add_header(*header)
        msg.attach(attachment)
    except IOError:
        msg = "Error opening attachment file %s" % file_to_attach
        print(msg)
        sys.exit(1)
    smtpObj = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT, timeout=60)
    smtpObj.login(EMAIL_HOST_USER, EMAIL_HOST_PASSWORD)
    smtpObj.sendmail(DEFAULT_FROM_EMAIL, addresses, msg.as_string())
    smtpObj.quit()
