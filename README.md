This is an end-to-end SQL data pipeline for a sports franchise. Transforms raw operational data into a Medallion architecture (Bronze to Gold) using CTEs and window functions to drive vizual dashboard in Tableau. This project was created to showcase a complete data journey. Taking raw sports franchise data and transforming it into actionable business intelligence. The goal was to step into the shoes of a General Manager of a struggling basketball team and build an analytics system that ownership could actually use to make decisions about the roster, staff, and stadium revenue.

I took this from the initial raw data all the way to a polished visualization, and I am incredibly proud of the final result.

### Project Links

-   **Interactive Dashboard:** [Tableau - Basketball Operations Dashboards](https://public.tableau.com/views/BasketBallOperations/ExecutiveDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

-   **Project Documentation:** [Notion - Basketball Operations Project Management](https://www.notion.so/Basketball-Operations-Revenue-Turnaround-32aa95054b5e8036a109f5ae8efe00df)

### The Business Problem

The St. Louis Archers needed a unified way to evaluate their franchise health. The raw data was scattered across ticket sales, merchandise transactions, staff evaluations, and on court player stats. Ownership needed a single pane of glass to see if the team was overpaying underperforming players, which staff members were hidden gems, and exactly what drove our stadium revenue.

### The Data Architecture

This project is using a Medallion pipeline to ensure the data was accurate, scalable, and ready for visualization.

-   **Bronze:** The raw, uncleaned CSV files straight from the operational systems.

-   **Silver:** The cleaned and standardized data housed inside SQL Server. This is where I audited for missing values, handled duplicates, and mapped primary and foreign keys.

-   **Gold:** The final export layer. I wrote advanced SQL queries utilizing Common Table Expressions, Window Functions, and Case Statements to build custom business thresholds and key performance indicators.

### The Code Directory

You will find my complete Exploratory Data Analysis and final reporting logic inside the sql folder. I organized the scripts chronologically so you can follow my thought process.

-   **Files 01 through 05:** Data exploration, auditing, and part to whole analysis. This proves the data was sound before any math was applied.

-   **Files 06 through 10:** The final business reports engineered specifically for Tableau. This includes the logic for grouping players into financial tiers and calculating our daily revenue baseline.

### The Visual Solution

For the front end, I designed an several dashboards for Players, Revenue, HR, and Executives in Tableau.

### Conclusion

Building this relational database project allowed me to learn a lot of new things and bridge the gap between backend data manipulation and frontend storytelling. Feel free to explore the SQL queries in this repository or click through the interactive Tableau dashboard linked above!
