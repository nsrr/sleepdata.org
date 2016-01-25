# Uses code from 4-2-stable for column_definitions in order to work with PG 8.4

require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def column_definitions(table_name)
        exec_query(<<-end_sql, 'SCHEMA').rows
            SELECT a.attname, format_type(a.atttypid, a.atttypmod),
                   pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod
              FROM pg_attribute a LEFT JOIN pg_attrdef d
                ON a.attrelid = d.adrelid AND a.attnum = d.adnum
             WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
               AND a.attnum > 0 AND NOT a.attisdropped
             ORDER BY a.attnum
        end_sql
      end
    end
  end
end
