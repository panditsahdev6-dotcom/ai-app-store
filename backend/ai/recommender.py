from collections import Counter

def recommend_apps(user_history, all_apps, limit=10):
    """
    user_history: list of categories user used/clicked
    all_apps: list of app dicts from database
    limit: max recommendations
    """

    if not user_history or not all_apps:
        return []

    # 🔥 Step 1: user interest count करो
    category_count = Counter(user_history)

    # 🔥 Step 2: हर app को score दो
    scored_apps = []

    for app in all_apps:
        category = app.get("category", "")

        # user interest के हिसाब से score
        score = category_count.get(category, 0)

        # downloads से boost
        downloads = app.get("downloads", 0)
        score += downloads * 0.01   # weight कम रखा है

        # rating से boost
        rating = app.get("rating", 0)
        score += rating * 0.5

        scored_apps.append((score, app))

    # 🔥 Step 3: score के हिसाब से sort करो
    scored_apps.sort(key=lambda x: x[0], reverse=True)

    # 🔥 Step 4: top apps return करो
    recommended = [app for score, app in scored_apps if score > 0]

    return recommended[:limit]