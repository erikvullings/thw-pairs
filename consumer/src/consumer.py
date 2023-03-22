from test_bed_adapter import (TestBedAdapter, TestBedOptions)
from test_bed_adapter.kafka.consumer_manager import ConsumerManager
from environs import Env
import time
import sys
import logging
import threading
import random
logging.basicConfig(level=logging.INFO)
sys.path += [".."]


class ConsumerExample:
    @staticmethod
    def main():
        _env = Env()

        CONSUME_ENV = _env('CONSUME', "request,inventory,resource")
        PRODUCE_ENV = _env('PRODUCE', None)
        CLIENT_ID_ENV = _env('CLIENT_ID', 'CONSUMER' +
                             str(random.randint(0, 9999999)))

        KAFKA_HOST = _env('KAFKA_HOST', 'localhost:9092')
        SCHEMA_REGISTRY = _env('SCHEMA_REGISTRY', 'http://localhost:3502')
        PARTITIONER = _env("PARTITIONER", "random")
        MESSAGE_MAX_BYTES = _env.int('MESSAGE_MAX_BYTES', 1000000)
        HEARTBEAT_INTERVAL = _env.int('HEARTBEAT_INTERVAL', 10)
        OFFSET_TYPE = _env('OFFSET_TYPE', 'latest')

        tb_options = {
            "kafka_host": KAFKA_HOST,
            "schema_registry": SCHEMA_REGISTRY,
            "partitioner": PARTITIONER,
            "consumer_group": CLIENT_ID_ENV,
            "message_max_bytes": MESSAGE_MAX_BYTES,
            "offset_type": OFFSET_TYPE,
            "heartbeat_interval": HEARTBEAT_INTERVAL
        }

        test_bed_options = TestBedOptions(tb_options)

        test_bed_adapter = TestBedAdapter(test_bed_options)

        # This funcion will act as a handler. It only prints the incoming messages
        def handle_message(message):
            return logging.info(" Incoming message: " + str(message))

        # We initialize the process (catching schemas and so on) and we listen the messages from the topic system_rss_feeds
        test_bed_adapter.initialize()

        listener_threads = []

        run = True

        # Create threads for each consume topic
        for topic in CONSUME_ENV.split(','):
            logging.info("Consuming topic " + topic)
            listener_threads.append(threading.Thread(
                target=ConsumerManager(
                    options=test_bed_options,
                    kafka_topic=topic,
                    handle_message=handle_message,
                    run=lambda: run
                ).listen)
            )

        # start all threads
        for thread in listener_threads:
            thread.daemon = True
            thread.start()

        # make sure we keep running until keyboardinterrupt

        while run:
            # make sure we check thread health every 10 sec
            time.sleep(10)
            for thread in listener_threads:
                if not thread.is_alive():
                    run = False
                    logging.error("Thread died, shutting down")

        # Stop test bed
        test_bed_adapter.stop()

        # Clean after ourselves
        for thread in listener_threads:
            thread.join()

        raise Exception


if __name__ == '__main__':
    ConsumerExample().main()
