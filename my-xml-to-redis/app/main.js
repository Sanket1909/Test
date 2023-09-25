// Import necessary modules
const fs = require('fs');
const xml2js = require('xml2js');
const redis = require('redis');
const { promisify } = require('util');

// Read the XML file
const xmlFilePath = '/my-xml-to-redis/config.xml'; 
const xmlData = fs.readFileSync(xmlFilePath, 'utf-8');


const redisClient = redis.createClient();
redisClient.on('error', (err) => {
  console.error('Redis error:', err);
});

const redisSetAsync = promisify(redisClient.set).bind(redisClient);


xml2js.parseString(xmlData, async (err, result) => {
  if (err) {
    console.error('Error parsing XML:', err);
    redisClient.quit(); 
    return;
  }

  try {
    
    const subdomains = result.config.subdomains[0].subdomain;

    
    await redisSetAsync('subdomains', JSON.stringify(subdomains));
    console.log('Subdomains exported to Redis.');
  } catch (error) {
    console.error('Error setting subdomains in Redis:', error);
  } finally {
    
    redisClient.quit();
  }
});
