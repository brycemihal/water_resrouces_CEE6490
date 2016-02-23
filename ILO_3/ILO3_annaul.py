import pymysql
import numpy as np
import matplotlib.pyplot as plt

# Connect to mysql database
conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='b', db='Corinne')
cur = conn.cursor()
# SQL query(s)
start_year = 1963
end_year = 2015
query1 = '''SELECT YEAR(LocalDateTime) AS theYear,
                AVG(Discharge) AS AvgCFS
            FROM results
            WHERE Discharge <> -999 AND YEAR(LocalDateTime) >''' + str(start_year) + '''
            AND YEAR(LocalDateTime) < ''' + str(end_year) + '''
            GROUP BY YEAR(LocalDateTime)
            ORDER BY theYear;'''
cur.execute(query1)
response = cur.fetchall()
# convert the response to an array
r_array = np.array(response)
months = r_array[:, 0]
actual_flows = r_array[:, 1] #cfs

# Save the table to a file
f = open("annual_result.csv", "w")
for row in response:
    f.write('"' + '","'.join([str(s) for s in row]) + '"')
    f.write('\n')
f.close()
conn.close()

# threshold for annual target water (ac-ft/mo)
target_flows = np.array([1]*len(actual_flows)) * 425760

#convert cfs to ac-ft/mo
actual_flows_acft = actual_flows * (1.0/43560.0) * 3600.0 * 24.0 * 365.0

# calculation of reliability -------------------------------
sat_time = sum(actual_flows_acft > target_flows)
#only look at 10 months because DEC and JAN are blank (-)
total_time = float(len(actual_flows))
# percent reliability
annual_rely = (sat_time/total_time)*100
print annual_rely

# calculation of resilience -------------------------------
recovery = [0]*len(actual_flows) #empty array of zeros (10 columns)
for i in range(1, len(actual_flows)):
    if actual_flows_acft[i-1] < target_flows[i-1] and actual_flows_acft[i] > target_flows[i]:
        recovery[i] = 1

annual_resil = sum(recovery)/(total_time-sat_time)*100
print annual_resil

# calculation of vulnerability -------------------------------
flow_diff = [0]*len(actual_flows) #empty array of zeros (10 columns)
for i in range(0, len(actual_flows)):
    if actual_flows_acft[i] < target_flows[i]:
        flow_diff[i] = abs(actual_flows_acft[i] - target_flows[i])

annual_vuln = sum(flow_diff)/(total_time-sat_time)
print annual_vuln

# Create Bar chart
fig, ax = plt.subplots()
index = np.arange(total_time)
years = np.array([start_year+1]*len(actual_flows))+range(len(actual_flows))
bar_width = 0.4
opacity = 0.4
bar1 = plt.bar(index, actual_flows_acft, bar_width, color='b', alpha=opacity, label='Actual Flows')
bar2 = plt.bar(index+bar_width, target_flows, bar_width, color='g', alpha=opacity, hatch='x', label='Target Flows')
plt.xlabel('Year')
plt.ylabel('Discharge (ac-ft/yr)')
plt.title('Average Annual Bear River Flows at Corinne Station (50 years)')
plt.xticks(index + bar_width, years, rotation=60)
plt.legend()
plt.show()
