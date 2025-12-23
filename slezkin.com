import logging
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
import random
import time

# Настройки логгера
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Словарь для хранения индивидуальных результатов пользователей
user_scores = {}

# Константы
COOLDOWN_TIME = 600  # Интервал ожидания в секундах (10 минут)

# Ваш токен здесь (НЕ ВКЛАДЫВАЙТЕ РЕАЛЬНЫЙ ТОКЕН ПУБЛИЧНО!)
TOKEN = "8407896293:AAGOctJgEkjxSzp00Hc12AsjA_5H5j3aAHg"

# Главная логика обработки команды "/steesigotdeem_traz_konch@SLEZKIIN_bot"
async def steesi_got_deem(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    now = time.time()

    # Проверьте, прошел ли нужный интервал времени
    if user_id in user_scores and (now - user_scores[user_id]['timestamp']) < COOLDOWN_TIME:
        remaining_time = COOLDOWN_TIME - (now - user_scores[user_id]['timestamp'])
        await update.message.reply_text(f"Стейси отравилась кефирчиком, жди еще {round(remaining_time)} секунд.")
        return

    # Генерация случайного числа
    score = random.randint(10, 60)

    # Обновление результата пользователя
    if user_id not in user_scores:
        user_scores[user_id] = {'total': 0, 'timestamp': now}
    user_scores[user_id]['total'] += score
    user_scores[user_id]['timestamp'] = now

    await update.message.reply_text(f"Вы выебали Слезкина {score} раз.")

# Основная логика обработки команды "/gordeemstaisy_profil@SLEZKIIN_bot"
async def gordeem_staisy(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    username = update.effective_user.username or update.effective_user.full_name

    if user_id not in user_scores:
        await update.message.reply_text(f"{username}: 0")
    else:
        total_score = user_scores[user_id]['total']
        await update.message.reply_text(f"{username}: {total_score}")

# Основной метод запуска приложения
def main():
    # Создаем объект приложения с вашим токеном
    application = Application.builder().token(TOKEN).build()

    # Регистрируем наши команды
    application.add_handler(CommandHandler("steesigotdeem_traz_konch@SLEZKIIN_bot", steesi_got_deem))
    application.add_handler(CommandHandler("gordeemstaisy_profil@SLEZKIIN_bot", gordeem_staisy))

    # Начинаем работу бота
    application.run_polling()

if __name__ == "__main__":
    main()
