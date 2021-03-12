import { MetricRepository } from './MetricRepository';
import { MetricModel, MetricType } from '../MetricModel';
import * as moment from 'moment';

export class StubMetricRepository implements MetricRepository {

  findAll(): Promise<MetricModel[]> {
    return Promise.resolve([
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        'Upload',
        moment().unix().toString(),
        (moment().unix() + 5).toString(),
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        'Renaming',
        moment().unix().toString(),
        (moment().unix() + 5).toString(),
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        MetricType.UNICORN_UPLOAD_FAILURE,
        moment().unix().toString(),
        null,
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        MetricType.UNICORN_UPLOAD_FAILURE,
        moment().unix().toString(),
        null,
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        MetricType.UNICORN_UPLOAD_FAILURE,
        moment().unix().toString(),
        null,
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        MetricType.UNICORN_UPLOAD_SUCCESS,
        moment().unix().toString(),
        null,
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        MetricType.UNICORN_UPLOAD_SUCCESS,
        moment().unix().toString(),
        null,
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        'Conversion',
        moment().unix().toString(),
        (moment().unix() + 5).toString(),
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        'Download',
        moment().unix().toString(),
        (moment().unix() + 5).toString(),
        null
      ),
      new MetricModel(
        '1',
        'e223sdfs23523sdfs',
        'Download',
        (moment().unix() - 7).toString(),
        moment().unix().toString(),
        null
      )
    ]);
  }

  create(metric: MetricModel) {
    return Promise.resolve(new MetricModel(3, 'testetstestes', 'Upload', moment().unix().toString(), null, null));
  }

  update(metric: MetricModel) {
    return Promise.resolve(new MetricModel(
      3,
      'testetstestes',
      'Upload',
      moment().unix().toString(),
      moment().unix().toString(),
      null)
    );
  }
}