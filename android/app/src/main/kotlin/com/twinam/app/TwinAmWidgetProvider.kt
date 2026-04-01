package com.twinam.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class TwinAmWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_counter).apply {
                // Get data from HomeWidget
                val widgetData = HomeWidgetPlugin.getData(context)
                
                // Update level
                val level = widgetData.getInt("level", 1)
                val levelTitle = widgetData.getString("levelTitle") ?: "Newbie"
                setTextViewText(R.id.widget_level, "Lvl $level")
                
                // Update progress
                val todayProgress = widgetData.getInt("todayProgress", 0)
                setProgressBar(R.id.widget_progress, 100, todayProgress, false)
                setTextViewText(R.id.widget_progress_text, "$todayProgress%")
                
                // Update stats
                val totalCounters = widgetData.getInt("totalCounters", 0)
                val goalsReached = widgetData.getInt("goalsReached", 0)
                setTextViewText(R.id.widget_counters_count, totalCounters.toString())
                setTextViewText(R.id.widget_goals_reached, goalsReached.toString())
                
                // Update top counters
                for (i in 0..2) {
                    val counterName = widgetData.getString("counter${i}_name")
                    val counterValue = widgetData.getInt("counter${i}_value", 0)
                    
                    if (counterName != null) {
                        setViewVisibility(getCounterLayoutId(i), android.view.View.VISIBLE)
                        setTextViewText(getCounterNameId(i), counterName)
                        setTextViewText(getCounterValueId(i), counterValue.toString())
                    } else {
                        setViewVisibility(getCounterLayoutId(i), android.view.View.GONE)
                    }
                }
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    
    private fun getCounterLayoutId(index: Int): Int {
        return when (index) {
            0 -> R.id.widget_counter_0
            1 -> R.id.widget_counter_1
            2 -> R.id.widget_counter_2
            else -> R.id.widget_counter_0
        }
    }
    
    private fun getCounterNameId(index: Int): Int {
        return when (index) {
            0 -> R.id.widget_counter_0_name
            1 -> R.id.widget_counter_1_name
            2 -> R.id.widget_counter_2_name
            else -> R.id.widget_counter_0_name
        }
    }
    
    private fun getCounterValueId(index: Int): Int {
        return when (index) {
            0 -> R.id.widget_counter_0_value
            1 -> R.id.widget_counter_1_value
            2 -> R.id.widget_counter_2_value
            else -> R.id.widget_counter_0_value
        }
    }
}
