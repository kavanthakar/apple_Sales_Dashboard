

\copy dim_product      FROM 'clean_csv/dim_product.csv'      WITH (FORMAT csv, HEADER true);
\copy dim_customer     FROM 'clean_csv/dim_customer.csv'     WITH (FORMAT csv, HEADER true);
\copy dim_store        FROM 'clean_csv/dim_store.csv'        WITH (FORMAT csv, HEADER true);
\copy dim_date         FROM 'clean_csv/dim_date.csv'         WITH (FORMAT csv, HEADER true);
\copy dim_market       FROM 'clean_csv/dim_market.csv'       WITH (FORMAT csv, HEADER true);
\copy fact_sales       FROM 'clean_csv/fact_sales.csv'       WITH (FORMAT csv, HEADER true);
\copy fact_marketing   FROM 'clean_csv/fact_marketing.csv'   WITH (FORMAT csv, HEADER true);
\copy fact_inventory   FROM 'clean_csv/fact_inventory.csv'   WITH (FORMAT csv, HEADER true);
\copy fact_tradein     FROM 'clean_csv/fact_tradein.csv'     WITH (FORMAT csv, HEADER true);
\copy fact_returns     FROM 'clean_csv/fact_returns.csv'     WITH (FORMAT csv, HEADER true);
