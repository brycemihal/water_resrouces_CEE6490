import pymysql
import numpy as np
import matplotlib.pyplot as plt

# Connect to mysql database
conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='b', db='Corinne')
cur = conn.cursor()
# SQL query(s)
start_year = 1963
end_year = 2015
query1 = '''SELECT MONTH(LocalDateTime) AS theMonth,
                AVG(Discharge) AS AvgCFS
            FROM results
            WHERE Discharge <> -999 AND YEAR(LocalDateTime) > ''' + str(start_year) + '''
            AND YEAR(LocalDateTime) < ''' + str(end_year) + '''
            GROUP BY MONTH(LocalDateTime)
            ORDER BY theMonth;'''
cur.execute(query1)
response = cur.fetchall()
# convert the response to an array
r_array = np.array(response)
months = r_array[:, 0]
actual_flows = r_array[:, 1] #cfs

# Save the table to a file
f = open("monthly_result.csv", "w")
for row in response:
    f.write('"' + '","'.join([str(s) for s in row]) + '"')
    f.write('\n')
f.close()
conn.close()

# threshold for monthly target water (ac-ft/mo)
target_flows = [0, 4258, 60884, 59181, 61309, 46834, 50240, 43002, 54497, 42150, 3406, 0]

#convert cfs to ac-ft/mo
month_days = np.array([31, 28.25, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])
actual_flows_acft = (actual_flows * month_days) * (1.0/43560.0) * 3600.0 * 24.0

# calculation of reliability -------------------------------
sat_time = sum(actual_flows_acft[1:11] > target_flows[1:11])
#only look at 10 months because DEC and JAN are blank (-)
total_time = 10.0
# percent reliability
monthly_rely = (sat_time/total_time)*100
print monthly_rely

# calculation of resilience -------------------------------
recovery = [0]*10 #empty array of zeros (10 columns)
for i in range(1, 11):
    if actual_flows_acft[1:11][i-1] < target_flows[1:11][i-1] and actual_flows_acft[1:11][i] > target_flows[1:11][i]:
        recovery[i] = 1

monthly_resil = sum(recovery)/(total_time-sat_time)*100
print monthly_resil

# calculation of vulnerability -------------------------------
flow_diff = [0]*10 #empty array of zeros (10 columns)
for i in range(0, 10):
    if actual_flows_acft[1:11][i] < target_flows[1:11][i]:
        flow_diff[i] = abs(actual_flows_acft[1:11][i] - target_flows[1:11][i])

monthly_vuln = sum(flow_diff)/(total_time-sat_time)
print monthly_vuln

# Create Bar chart
months = 12.0
fig, ax = plt.subplots()
index = np.arange(months)
bar_width = 0.35
opacity = 0.4
bar1 = plt.bar(index, actual_flows_acft, bar_width, color='b', alpha=opacity, label='Actual Flows')
bar2 = plt.bar(index+bar_width, target_flows, bar_width, color='g', alpha=opacity, hatch='x', label='Target Flows')
plt.xlabel('Month')
plt.ylabel('Discharge (ac-ft/mo)')
plt.title('Average Monthly Bear River Flows at Corinne Station (25 years)')
plt.xticks(index + bar_width, ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
plt.legend()
# plt.tight_layout()
plt.show()