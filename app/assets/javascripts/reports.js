function getCycleTimeChartData(url) {
  return $.getJSON(url).then(function(json){
    return convertToCycleTimeChartData(json);
  });
}

function convertToCycleTimeChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[3]);
    memo[1].push(cycle_time_record[4]);
    return memo;
  }, [['cycle_time_x'], ['cycle time']]);

  var regression_data = data.cycle_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.cycle_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function convertToShortCycleTimeChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[2]);
    memo[1].push(cycle_time_record[5]);
    return memo;
  }, [['cycle_time_x'], ['cycle time']]);

  var regression_data = data.short_cycle_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.short_cycle_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function convertToCycleTimeDeltaChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[3]);
    memo[1].push(cycle_time_record[6]);
    return memo;
  }, [['cycle_time_x'], ['cycle time delta']]);

  var regression_data = data.cycle_delta_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.cycle_delta_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function getDeploymentChartData(url) {
  return $.getJSON(url).then(function(data){
    return convertToDeploymentChartData(data);
  });
}

function convertToDeploymentChartData(data) {
  var deployments = data.issue_count_per_day.reduce(function(memo, deployment_record){
    memo[0].push(deployment_record[0]);
    memo[1].push(deployment_record[1]);
    return memo;
  }, [['deployment_x'], ['deployments']]);

  var regression_data = data.trend_count_per_week.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  return deployments.concat(regression_data);
}

function convertToCumulativeOverviewChartData(data, set_goal) {
  var dates = data.current.map(function(x){
    return x[0];
  });

  var min_max_dates = ['min_max_dates', dates[0], dates[dates.length - 1]];
  var goal = ['goal', 0, set_goal];

  dates = ['dates'].concat(dates);

  var current = data.current.map(function(x){
    return x[1];
  });
  current = ['current_x'].concat(current);

  var previous = data.previous.map(function(x){
    return x[1];
  });
  previous = ['previous_x'].concat(previous);

  return [min_max_dates, dates, current, previous, goal];
}

function convertToCumulativeP1ChartData(data, set_goal) {
  var dates = data.cumulative_count_per_label_per_day[0].issue_count.map(function(x){
    return x[0];
  });

  result = [['dates'].concat(dates)];

  data.cumulative_count_per_label_per_day.forEach(function(hash){
    data = hash.issue_count.map(function(x){
      return x[1];
    });
    result.push([hash.label].concat(data));
  })

  return result;
}
function convertToP1IssueCountChartData(data) {
  var p1count = data.issue_count_per_week.reduce(function(memo, issue_count){
    memo[0].push(issue_count[0]);
    memo[1].push(issue_count[1]);
    return memo;
  }, [['issue_count_x'], ['issues per week']]);

  var regression_data = data.trend_count_per_week.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  return p1count.concat(regression_data);
}

function convertToResolutionTimeChartData(data) {
  var resolution_time_data = data.closed_issues_table.slice(1).reduce(function(memo, resolution_time_record){
    memo[0].push(resolution_time_record[1]);
    memo[1].push(resolution_time_record[3]);
    return memo;
  }, [['cycle_time_x'], ['resolution time']]);

  var regression_data = data.trend_resolution_time.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.resolution_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return resolution_time_data.concat(regression_data).concat(moving_averages_data);
}

function generateScatterPlot(chart_data, start_date, css_selector, variable_name) {
  xs = {};
  xs[variable_name] = 'cycle_time_x';
  xs['trendline'] = 'trendline_x';
  xs['moving average'] = 'moving_average_x';

  c3.generate({
    padding: {
       right: 40,
       left: 40
    },
    bindto: d3.select(css_selector),
    data: {
      xs: xs,
      columns: chart_data,
      type: 'scatter',
      types: {
        trendline: 'line',
        'moving average': 'line'
      }
    },
    axis: {
      y: {
        min: 0,
        padding: { top: 5, bottom:0 }
      },
      x: {
        min: Date.parse(start_date),
        type: 'timeseries',
        tick: {
         fit: true,
         count: 6,
         format: '%d-%m-%Y'
        }
      }
    },
    point: {
      r: 5,
      show: false
    }
  });
}
