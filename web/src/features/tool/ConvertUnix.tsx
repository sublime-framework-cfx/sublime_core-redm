import moment from 'moment';
import { fetchNui } from '../../utils/fetchNui';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import type { ConvertUnixProps } from '../../typings/ConvertUnix';

const ConvertUnixTime: React.FC = () => {
  useNuiEvent('supv:convert:unix', (data: ConvertUnixProps) => {
    const unixTime: number = moment.duration(data.unix_time, 'milliseconds').as('seconds');
    const date: any|string = moment.unix(unixTime).format(data.format_date);
    fetchNui('supv:convert:return-unix', date);
  });

  return (
    <></>
  );
};

export default ConvertUnixTime;