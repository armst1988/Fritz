/// <reference path="../steps.d.ts" />

Feature('Metrics Page');

Scenario('should display some metrics and the average time for the actions', (I) => {
  I.amOnPage('/metrics');
  I.see('Avg. Workflow Time');
  I.see('Avg. Upload Time');
  I.see('Avg. Rename Time');
  I.see('Avg. Download Time');
  I.see('Avg. Conversion Time');
  I.click('#activityLogButton');
  I.waitForText('e23523', 5);
});