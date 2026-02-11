package com.example.quan_ly_chi_tieu

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.example.quan_ly_chi_tieu.R
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.NumberFormat
import java.util.Locale
import android.app.PendingIntent
import android.content.Intent
class ExpenseWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        val prefs = HomeWidgetPlugin.getData(context)
        val amount = prefs
            .getString("today_expense", "0")!!
            .toInt()

        val formatted = NumberFormat
            .getNumberInstance(Locale("vi", "VN"))
            .format(amount) + " ₫"

        for (id in appWidgetIds) {

            val views = RemoteViews(
                context.packageName,
                R.layout.widget_expense
            )

            views.setTextViewText(
                R.id.tvAmount,
                formatted
            )

            // 🔥 Scan button
            val scanIntent = Intent(context, MainActivity::class.java)
            scanIntent.putExtra("route", "/scan")

            val scanPendingIntent = PendingIntent.getActivity(
                context,
                0,
                scanIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.btnScan, scanPendingIntent)

            // 🔥 Add button
            val addIntent = Intent(context, MainActivity::class.java)
            addIntent.putExtra("route", "/add-transaction")

            val addPendingIntent = PendingIntent.getActivity(
                context,
                1,
                addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.btnAdd, addPendingIntent)

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
