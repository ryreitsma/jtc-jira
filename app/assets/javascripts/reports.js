function getCycleTimeChartData(url) {
  return $.getJSON(url).then(function(data){
    var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
      memo[0].push(cycle_time_record[2]);
      memo[1].push(cycle_time_record[3]);
      return memo;
    }, [['cycle_time_x'], ['cycle time']]);

    var regression_data = data.regression.reduce(function(memo, regression_record){
      memo[0].push(regression_record[0]);
      memo[1].push(regression_record[1]);
      return memo;
    }, [['trendline_x'], ['trendline']]);

    var moving_averages_data = data.moving_averages.reduce(function(memo, average_record){
      memo[0].push(average_record[0]);
      memo[1].push(average_record[1]);
      return memo;
    }, [['moving_average_x'], ['moving average']]);

    return cycle_time_data.concat(regression_data).concat(moving_averages_data);
  });
}

function getDeploymentChartData(url) {
  return $.getJSON(url).then(function(data){
    var deployments = data.table.slice(1).reduce(function(memo, deployment_record){
      memo[0].push(deployment_record[0]);
      memo[1].push(deployment_record[1]);
      return memo;
    }, [['deployment_x'], ['deployments']]);

    var regression_data = data.regression.reduce(function(memo, regression_record){
      memo[0].push(regression_record[0]);
      memo[1].push(regression_record[1]);
      return memo;
    }, [['trendline_x'], ['trendline']]);

    return deployments.concat(regression_data);
  });
}
