namespace :tracker do

  PROJECTS = [
    'Java',
    '.NET',
    'Python',
    'PHP',
    'PHPv2',
    'Ruby',
    'JavaScript',
    'iOS',
    'Android'
  ]

  
  SERVICES = [
    ['Amazon CloudFront',                         'CloudFront'],
    ['Amazon CloudSearch',                        'CloudSearch'],
    ['Amazon CloudWatch',                         'CloudWatch'],
    ['Amazon DynamoDB',                           'DynamoDB'],
    ['Amazon ElastiCache',                        'ElastiCache'],
    ['Amazon Elastic Block Store (EBS)',          'EBS'],
    ['Amazon Elastic Compute Cloud',              'EC2'],
    ['Amazon Elastic Map Reduce',                 'EMR'],
    ['Amazon Glacier',                            'Glacier'],
    ['Amazon Relational Database Service (Beta)', 'RDS'],
    ['Amazon Route53',                            'Route53'],
    ['Amazon Simple Email Service',               'SES'],
    ['Amazon Simple Notification Service (Beta)', 'SNS'],
    ['Amazon Simple Queue Service',               'SQS'],
    ['Amazon Simple Storage Service',             'S3'],
    ['Amazon Simple Workflow Service',            'SWF'],
    ['Amazon SimpleDB (Beta)',                    'SimpleDB'],
    ['Amazon Virtual Private Cloud',              'VPC'],
    ['Auto Scaling',                              'Auto Scaling'],
    ['AWS CloudFormation',                        'CloudFormation'],
    ['AWS Data Pipeline',                         'Data Pipeline'],
    ['AWS Direct Connect',                        'Direct Connect'],
    ['AWS Elastic Beanstalk',                     'Elastic Beanstalk',],
    ['AWS Identity and Access Management',        'IAM'],
    ['AWS Import/Export',                         'Import/Export'],
    ['AWS Security Token Service',                'STS'],
    ['AWS Storage Gateway',                       'Storage Gateway'],
    ['Elastic Load Balancing',                    'ELB']
  ]

  SUPPORTED_SERVICES = [
    ['Java', [
                  'CloudFront',
                  'CloudSearch',
                  'CloudWatch',
                  'DynamoDB',
                  'ElastiCache',
                  'EC2',
                  'EMR',
                  'Glacier',
                  'RDS',
                  'Route53',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SWF',
                  'SimpleDB',
                  'Auto Scaling',
                  'CloudFormation',
                  'Elastic Beanstalk',
                  'IAM',
                  'Import/Export',
                  'STS',
                  'Storage Gateway',
                  'ELB'
                ]
    ],
    ['.NET', [
                  'CloudFront',
                  'CloudSearch',
                  'CloudWatch',
                  'DynamoDB',
                  'ElastiCache',
                  'EC2',
                  'EMR',
                  'Glacier',
                  'RDS',
                  'Route53',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SWF',
                  'SimpleDB',
                  'Auto Scaling',
                  'CloudFormation',
                  'Elastic Beanstalk',
                  'IAM',
                  'Import/Export',
                  'STS',
                  'Storage Gateway',
                  'ELB'
                ]
    ],
    ['PHP',  [
                  'CloudFront',
                  'CloudSearch',
                  'CloudWatch',
                  'DynamoDB',
                  'ElastiCache',
                  'EC2',
                  'EMR',
                  'RDS',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SWF',
                  'SimpleDB',
                  'Auto Scaling',
                  'CloudFormation',
                  'Elastic Beanstalk',
                  'IAM',
                  'Import/Export',
                  'STS',
                  'Storage Gateway',
                  'ELB'
                ]
    ],
    ['PHPv2',  [
                  'CloudFront',
                  'DynamoDB',
                  'Glacier',
                  'S3',
                  'STS'
                ]
    ],
    ['Ruby', [
                  'CloudSearch',
                  'CloudWatch',
                  'DynamoDB',
                  'ElastiCache',
                  'EC2',
                  'EMR',
                  'RDS',
                  'Route53',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SWF',
                  'SimpleDB',
                  'Auto Scaling',
                  'CloudFormation',
                  'Elastic Beanstalk',
                  'IAM',
                  'STS',
                  'ELB'
                ]
    ],
    ['JavaScript', [
                    'DynamoDB',
                    'EC2',
                    'S3',
                    'SWF'
                  ]
    ],
    ['iOS', [
                  'CloudWatch',
                  'DynamoDB',
                  'EC2',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SimpleDB',
                  'Auto Scaling',
                  'STS',
                  'ELB'
                ]
    ],
    ['Android', [
                  'CloudWatch',
                  'DynamoDB',
                  'EC2',
                  'SES',
                  'SNS',
                  'SQS',
                  'S3',
                  'SimpleDB',
                  'Auto Scaling',
                  'STS',
                  'ELB'
                ]
    ]
  ]

  desc 'Install Tracker'
  task install: :environment do
    PROJECTS.each do |project|
      Project.where(name:project).first_or_create
    end
  
    SERVICES.each do |service|
      Service.where(name:service[0], abbreviation:service[1]).first_or_create
    end

    SUPPORTED_SERVICES.each do |project|
      project, services = project
      project = Project.with_name(project).first
      services = services.map {|service| Service.with_abbreviation(service).first}
      project.services << services
    end
  end
  
  SAMPLE_FEATURES = [
    # Title - Service - Release Date - CU
    [ 'FizzBuzz Generator', 'SWF', '2013-01-12', 123 ],
    [ 'Instance Modulator', 'EC2', '2013-01-31', 111 ],
    [ 'Data Destroyer', 'DynamoDB', '2013-02-05', 666],
    [ 'Dead Letter Box', 'SES', '2013-01-10', 124],
    [ 'Task Dropper', 'SQS', '2013-01-28', 234],
    [ 'No-One\'s Data Compression', 'S3', '2013-03-11', 235 ],
    [ 'Data Dribbler', 'CloudWatch', '2013-02-12', 324],
    [ 'Scale-a-matic', 'Auto Scaling', '2013-03-22', 236],
    [ '"Dear John" Creator', 'SES', '2013-01-23', 233],
    [ 'Bucket Washer', 'S3', '2013-03-02', 321]
  ]
  
  desc 'Add sample data'
  task install_sample: :environment do
    Feature.delete_all
    Story.delete_all
    
    SAMPLE_FEATURES.each do |title, service, release_date, cu|
      f = Feature.create(title:title, service_id:Service.with_abbreviation(service).first.id, release_date:release_date, contact_us_number:cu)
      Story.ensure_feature_stories(f)
    end
  end
  
  desc 'Destroy all'
  task destroy: :environment do
    Feature.delete_all
    Project.delete_all
    Service.delete_all
    Story.delete_all
    SupportedService.delete_all
  end
  
  namespace :project do

    desc 'Ensure all projects have start dates'
    task ensure_start_dates: :environment do
      Project.where(start_date: nil).update_all(start_date: DateTime.parse('2012-12-01'))
    end

  end

  namespace :task do

    desc 'Ensure task dates'
    task ensure_dates: :environment do
      Task.where("status in (?)", [:completed, :in_progress]).where(start_date: nil).each do |task|
        task.update_attribute(:start_date, Iteration.new(task.project.team).start_date) if task.start_date.blank?
      end
      Task.where(status: :completed).where(completed_date: nil).each do |task|
        task.update_attribute(:completed_date, Iteration.new(task.project.team).start_date) if task.completed_date.blank?
      end
    end

    desc 'Ensure project task order'
    task ensure_order: :environment do
      Task.where(status: :completed).all.each {|t| t.ensure_rank; t.save}
      Task.where(status: :in_progress).all.each {|t| t.ensure_rank; t.save}
      # Task.where(status: :pending).all.each {|t| t.save}
    end

    desc 'Reset task ranks'
    task reset_ranks: :environment do
      tasks = Task.in_rank_order
      rank = 1
      tasks.each do |task|
        task.update_column(:rank, rank)
        rank += 1
      end
    end

  end

end
